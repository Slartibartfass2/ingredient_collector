import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/local_storage/local_storage_migration.dart';
import 'package:ingredient_collector/src/models/local_storage/versions/local_storage_data_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  test(
    'When local storage is empty, then return empty storage object',
    () async {
      SharedPreferences.setMockInitialValues({});
      var localStorageData = await LocalStorageMigration().migrate();
      expect(localStorageData.additionalRecipeInformation, isEmpty);
      expect(localStorageData.version, 1);
    },
  );

  test('When storage holds version 0, then migrate to version 1', () {
    SharedPreferences.setMockInitialValues({
      "additional_recipe_informations": [],
    });
  });
}
