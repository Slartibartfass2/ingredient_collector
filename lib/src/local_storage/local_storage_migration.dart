import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_storage/versions/local_storage_data_v1.dart';
import 'local_storage_controller.dart';

/// Migration logic for the local storage.
///
/// First it tries to determine the version and then migrate the local storage.
class LocalStorageMigration {
  /// Migrates the local storage.
  Future<LocalStorageDataV1> migrate() async {
    var store = await SharedPreferences.getInstance();
    var localStorageData = store.get(LocalStorageController.localStorageDataKey)
        as Map<String, dynamic>?;
    if (localStorageData == null) {
      // Delete old local storage
      await store.remove("additional_recipe_informations");
      return LocalStorageDataV1(additionalRecipeInformation: []);
    }
    var version = int.tryParse(localStorageData["version"]);
    if (version == null) {
      await _removeLocalStorageData(store);
      return LocalStorageDataV1(additionalRecipeInformation: []);
    }
    var ignored = switch (version) {
      1 => await migrateFrom1to2(localStorageData as String),
      _ => throw Exception()
    };
    return LocalStorageDataV1(additionalRecipeInformation: []);
  }

  /// Migrates.
  Future<void> migrateFrom1to2(String data) async {
    var parsedData = jsonDecode(data) as LocalStorageDataV1;
  }

  /// Removes existing [LocalStorageDataV1] object.
  Future<void> _removeLocalStorageData(SharedPreferences store) async {
    await store.remove(LocalStorageController.localStorageDataKey);
  }
}
