import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/data/datasources/route_fleet_remote_data_source.dart';

void main() {
  group('FleetCompanyModel parsing', () {
    test('parses successfully when driversCount is String and address is String', () {
      final json = {
        'id': 'comp-1',
        'name': 'Red Sea Express',
        'address': 'Al Hamra',
        'driversCount': '48',
      };
      final model = FleetCompanyModel.fromJson(json);
      expect(model.id, 'comp-1');
      expect(model.name, 'Red Sea Express');
      expect(model.address, 'Al Hamra');
      expect(model.driversCount, '48');
    });

    test('parses successfully when driversCount is int and address is null', () {
      final json = {
        '_id': 'comp-2',
        'companyName': 'KTN Wears',
        'drivers_count': 23,
      };
      final model = FleetCompanyModel.fromJson(json);
      expect(model.id, 'comp-2');
      expect(model.name, 'KTN Wears');
      expect(model.address, null);
      expect(model.driversCount, '23');
    });

    test('throws FormatException when id or name is missing', () {
      final json = {
        'address': 'Al Hamra',
      };
      expect(() => FleetCompanyModel.fromJson(json), throwsA(isA<FormatException>()));
    });
  });
}
