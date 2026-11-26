import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../version.dart';

/// A newer release on GitHub.
class UpdateInfo {
  const UpdateInfo({required this.version, required this.pageUrl, this.apkUrl});

  final String version;

  /// Release page, opened in the browser.
  final String pageUrl;

  /// Direct APK download, when the release has one.
  final String? apkUrl;
}

/// Compares dotted versions like `0.10.2`; a leading `v` is ignored.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.replaceFirst(RegExp('^v'), '').split('.'))
      int.tryParse(p.split(RegExp('[^0-9]')).first) ?? 0,
  ];
  final x = parts(a);
  final y = parts(b);
  for (var i = 0; i < x.length || i < y.length; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}

/// Reads a GitHub "latest release" response. Null when it isn't newer.
UpdateInfo? parseLatestRelease(
  Map<String, dynamic> json, {
  String current = appVersion,
}) {
  final tag = json['tag_name'];
  final page = json['html_url'];
  if (tag is! String || page is! String) return null;
  if (compareVersions(tag, current) <= 0) return null;
  String? apk;
  for (final a in (json['assets'] as List?) ?? const []) {
    final name = (a as Map<String, dynamic>)['name'];
    if (name is String && name.endsWith('.apk')) {
      apk = a['browser_download_url'] as String?;
      break;
    }
  }
  return UpdateInfo(
    version: tag.replaceFirst(RegExp('^v'), ''),
    pageUrl: page,
    apkUrl: apk,
  );
}

/// Reads the tag from where `github.com/{repo}/releases/latest` redirects,
/// e.g. ".../releases/tag/v0.9.0". Null when it isn't newer.
UpdateInfo? parseLatestRedirect(
  String location, {
  String repo = UpdateCheck.repo,
  String current = appVersion,
}) {
  final match = RegExp(r'/releases/tag/([^/?#]+)').firstMatch(location);
  if (match == null) return null;
  final tag = Uri.decodeComponent(match.group(1)!);
  if (compareVersions(tag, current) <= 0) return null;
  final base = 'https://github.com/$repo/releases';
  return UpdateInfo(
    version: tag.replaceFirst(RegExp('^v'), ''),
    pageUrl: '$base/tag/$tag',
    // The release workflow names the file dose-<tag>.apk.
    apkUrl: '$base/download/$tag/dose-$tag.apk',
  );
}

abstract final class UpdateCheck {
  static const repo = 'arsytyi/Dose';
  static final _latest = Uri.parse(
    'https://api.github.com/repos/$repo/releases/latest',
  );
  static final _latestPage = Uri.parse(
    'https://github.com/$repo/releases/latest',
  );

  /// [checked] is false when GitHub couldn't be reached; [update] is null
  /// when nothing is newer. The API allows only 60 requests an hour per
  /// address (mobile networks share addresses), so when it refuses, the
  /// public releases page is asked instead.
  static Future<({bool checked, UpdateInfo? update})> check() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final api = await _fromApi(client);
      if (api != null) return api;
      return await _fromPage(client) ?? (checked: false, update: null);
    } finally {
      client.close();
    }
  }

  static Future<({bool checked, UpdateInfo? update})?> _fromApi(
    HttpClient client,
  ) async {
    try {
      final req = await client.getUrl(_latest);
      req.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'Dose-app');
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        debugPrint('Update check: API answered ${res.statusCode}');
        await res.drain<void>();
        return null;
      }
      final body = await res.transform(utf8.decoder).join();
      return (
        checked: true,
        update: parseLatestRelease(jsonDecode(body) as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  static Future<({bool checked, UpdateInfo? update})?> _fromPage(
    HttpClient client,
  ) async {
    try {
      final req = await client.getUrl(_latestPage);
      req
        ..followRedirects = false
        ..headers.set(HttpHeaders.userAgentHeader, 'Dose-app');
      final res = await req.close().timeout(const Duration(seconds: 15));
      await res.drain<void>();
      final location = res.headers.value(HttpHeaders.locationHeader);
      if (!res.isRedirect || location == null) return null;
      return (checked: true, update: parseLatestRedirect(location));
    } catch (e) {
      debugPrint('Update check (page) failed: $e');
      return null;
    }
  }
}
