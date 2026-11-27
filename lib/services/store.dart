import 'package:flutter/services.dart' show appFlavor;

/// Where this build is distributed, from the Android product flavor.
abstract final class Store {
  /// The GitHub APK can check GitHub Releases for a newer version.
  /// The Google Play build cannot: Play delivers its updates, and the build
  /// has no network permission.
  static bool get selfUpdates => appFlavor == 'github';
}
