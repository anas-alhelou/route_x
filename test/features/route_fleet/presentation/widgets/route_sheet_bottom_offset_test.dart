// test/features/route_fleet/presentation/widgets/route_sheet_bottom_offset_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppSizes.sheetBottomGap is 26.0 dp matching Figma gap for in-route sheets', () {
    expect(AppSizes.sheetBottomGap, 26.0);
  });
}
