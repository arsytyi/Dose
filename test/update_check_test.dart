import 'dart:io';

import 'package:bady/services/update_check.dart';
import 'package:bady/version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compares versions numerically', () {
    expect(compareVersions('0.10.0', '0.9.9'), 1);
    expect(compareVersions('v1.0', '1.0.0'), 0);
    expect(compareVersions('0.6.0', '0.6.1'), -1);
  });

  test('finds a newer release and its APK', () {
    final u = parseLatestRelease({
      'tag_name': 'v0.7.0',
      'html_url': 'https://github.com/arsytyi/Dose/releases/tag/v0.7.0',
      'assets': [
        {'name': 'notes.txt', 'browser_download_url': 'x'},
        {'name': 'dose-v0.7.0.apk', 'browser_download_url': 'apk-url'},
      ],
    }, current: '0.6.0');
    expect(u?.version, '0.7.0');
    expect(u?.apkUrl, 'apk-url');
  });

  test('same or older release is not an update', () {
    expect(
      parseLatestRelease({
        'tag_name': 'v0.6.0',
        'html_url': 'x',
      }, current: '0.6.0'),
      isNull,
    );
    expect(parseLatestRelease({'message': 'Not Found'}), isNull);
  });

  test('lib/version.dart matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final v = RegExp(
      r'^version: ([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(appVersion, v);
  });

  test('falls back to the releases page redirect', () {
    final u = parseLatestRedirect(
      'https://github.com/arsytyi/Dose/releases/tag/v0.9.0',
      current: '0.8.0',
    )!;
    expect(u.version, '0.9.0');
    expect(u.pageUrl, 'https://github.com/arsytyi/Dose/releases/tag/v0.9.0');
    expect(
      u.apkUrl,
      'https://github.com/arsytyi/Dose/releases/download/v0.9.0/dose-v0.9.0.apk',
    );
    expect(
      parseLatestRedirect(
        'https://github.com/arsytyi/Dose/releases/tag/v0.9.0',
        current: '0.9.0',
      ),
      isNull,
    );
    expect(parseLatestRedirect('https://github.com/login'), isNull);
  });
}
