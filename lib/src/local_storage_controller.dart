import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/additional_recipe_information.dart';

/// Controller for the local storage.
///
/// The local storage is used to save [AdditionalRecipeInformation]s.
class LocalStorageController {
  /// Returns the [AdditionalRecipeInformation] for the recipe with the given
  /// [recipeUrlOrigin].
  ///
  /// Returns null if no [AdditionalRecipeInformation] is found.
  ///
  /// If the content of the local storage is invalid, it is cleared and null is
  /// returned.
  Future<AdditionalRecipeInformation?> getAdditionalRecipeInformation(
    String recipeUrlOrigin,
  ) async {
    var store = await SharedPreferences.getInstance();
    var jsonList = store.getStringList("additional_recipe_informations");

    if (jsonList == null || jsonList.isEmpty) {
      return null;
    }

    var additionalRecipeInformations = _getAdditionalRecipeInformations(
      jsonList,
      () async {
        await store.remove("additional_recipe_informations");
      },
    );

    var matches = additionalRecipeInformations.where(
      (element) => element.recipeUrlOrigin == recipeUrlOrigin,
    );

    return matches.isEmpty ? null : matches.first;
  }

  /// Saves the given [additionalRecipeInformation] to the local storage.
  ///
  /// If the content of the local store is invalid, it is cleared.
  /// If the given [additionalRecipeInformation] is already saved, it is
  /// overwritten, otherwise it is added.
  Future<void> setAdditionalRecipeInformation(
    AdditionalRecipeInformation additionalRecipeInformation,
  ) async {
    var store = await SharedPreferences.getInstance();
    var jsonList = store.getStringList("additional_recipe_informations");

    // If there was no additional recipe information saved yet, save the given
    // additional recipe information.
    if (jsonList == null || jsonList.isEmpty) {
      await store.setStringList(
        "additional_recipe_informations",
        [jsonEncode(additionalRecipeInformation.toJson())],
      );
      return;
    }

    var additionalRecipeInformations = _getAdditionalRecipeInformations(
      jsonList,
      () async {
        await store.remove("additional_recipe_informations");
      },
    );

    var matches = additionalRecipeInformations.where(
      (element) =>
          element.recipeUrlOrigin ==
          additionalRecipeInformation.recipeUrlOrigin,
    );

    // Overwrite the saved additional recipe information if it already exists.
    if (matches.isNotEmpty) {
      additionalRecipeInformations.remove(matches.first);
    }
    additionalRecipeInformations.add(additionalRecipeInformation);

    await store.setStringList(
      "additional_recipe_informations",
      additionalRecipeInformations.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  List<AdditionalRecipeInformation> _getAdditionalRecipeInformations(
    List<String> jsonList,
    void Function() onFormatException,
  ) {
    var additionalRecipeInformations = <AdditionalRecipeInformation>[];
    for (var jsonString in jsonList) {
      try {
        additionalRecipeInformations.add(
          AdditionalRecipeInformation.fromJson(
            jsonDecode(jsonString),
          ),
        );
      } on FormatException {
        onFormatException();
        return [];
      }
    }
    return additionalRecipeInformations;
  }
}
