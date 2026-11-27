import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../providers.dart';
import 'settings.dart';
import 'store.dart';

/// The one-time product created in Play Console (Monetize > Products >
/// In-app products). Never rename it: past buyers own this id.
const proProductId = 'dose_pro';

enum ProStatus { idle, buying, pending, error }

class ProState {
  const ProState({
    required this.unlocked,
    this.price,
    this.status = ProStatus.idle,
    this.error,
  });

  final bool unlocked;

  /// Localized price from Google Play, once known.
  final String? price;
  final ProStatus status;
  final String? error;

  ProState copyWith({
    bool? unlocked,
    String? price,
    ProStatus? status,
    String? error,
  }) => ProState(
    unlocked: unlocked ?? this.unlocked,
    price: price ?? this.price,
    status: status ?? this.status,
    error: error,
  );
}

/// Dose Pro: a single purchase through Google Play, remembered on the phone
/// so Pro works offline, and checked against Play on every start.
class ProController extends Notifier<ProState> {
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  @override
  ProState build() {
    ref.onDispose(() => _sub?.cancel());
    return ProState(unlocked: Prefs.pro(ref.read(sharedPreferencesProvider)));
  }

  /// Connects to Google Play: listens for purchases, loads the price, and
  /// reads past purchases (a reinstall restores Pro, a refund removes it).
  Future<void> connect() async {
    if (!Store.sellsPro || _sub != null) return;
    try {
      final iap = InAppPurchase.instance;
      _sub = iap.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) => _fail('$e'),
      );
      if (!await iap.isAvailable()) return;
      final details = await iap.queryProductDetails({proProductId});
      if (details.productDetails.isNotEmpty) {
        _product = details.productDetails.first;
        state = state.copyWith(price: _product!.price);
      }
      final past = await iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .queryPastPurchases();
      if (past.error != null) return;
      final owned = past.pastPurchases.where(
        (p) => p.productID == proProductId && _isOwned(p.status),
      );
      for (final p in owned) {
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
      }
      await _setUnlocked(owned.isNotEmpty);
    } catch (_) {
      // Offline or Play is unavailable: keep what the phone remembers.
    }
  }

  /// Opens Google Play's purchase sheet. The result arrives on the stream.
  Future<void> buy() async {
    await connect();
    final product = _product;
    if (product == null) {
      _fail(null);
      return;
    }
    state = state.copyWith(status: ProStatus.buying);
    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      _fail('$e');
    }
  }

  /// Asks Google Play again, e.g. after buying on another phone.
  Future<void> restore() async {
    if (!Store.sellsPro) return;
    _sub?.cancel();
    _sub = null;
    await connect();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != proProductId) continue;
      switch (p.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(status: ProStatus.pending);
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          await _setUnlocked(true);
          state = state.copyWith(status: ProStatus.idle);
        case PurchaseStatus.error:
          _fail(p.error?.message);
        case PurchaseStatus.canceled:
          state = state.copyWith(status: ProStatus.idle);
      }
      // Play refunds a purchase that isn't acknowledged within 3 days.
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  static bool _isOwned(PurchaseStatus s) =>
      s == PurchaseStatus.purchased || s == PurchaseStatus.restored;

  Future<void> _setUnlocked(bool unlocked) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if ((prefs.getBool(Prefs.proUnlocked) ?? false) == unlocked &&
        state.unlocked == unlocked) {
      return;
    }
    await prefs.setBool(Prefs.proUnlocked, unlocked);
    state = state.copyWith(unlocked: Prefs.pro(prefs));
    // Restock reminders and the chosen sound depend on Pro.
    ref.invalidate(reminderSettingsProvider);
    await ref.read(reminderSyncProvider).resync();
  }

  void _fail(String? message) =>
      state = state.copyWith(status: ProStatus.error, error: message);
}

final proProvider = NotifierProvider<ProController, ProState>(
  ProController.new,
);

/// Whether Pro features are open.
final isProProvider = Provider<bool>((ref) => ref.watch(proProvider).unlocked);
