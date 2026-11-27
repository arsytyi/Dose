import 'package:flutter/services.dart' show appFlavor;

/// Where this build is distributed, from the Android product flavor.
abstract final class Store {
  /// The GitHub APK can check GitHub Releases for a newer version.
  /// The Google Play build cannot: Play delivers its updates, and the build
  /// has no network permission.
  static bool get selfUpdates => appFlavor == 'github';

  /// Only the Google Play build sells Dose Pro (through Play Billing).
  /// Other builds open every feature.
  static bool get sellsPro => debugSellsPro ?? appFlavor == 'play';

  /// Tests set this to check the Play build's Pro locks.
  static bool? debugSellsPro;
}
