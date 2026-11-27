import 'package:bady/services/store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only the GitHub build checks for updates', () {
    // Tests run without a flavor, like any build that isn't the GitHub APK.
    expect(Store.selfUpdates, isFalse);
  });
}
