import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/additional_recipe_information.dart';

/// Controller for the local store.
class LocalStoreController {
  /// Returns the [AdditionalRecipeInformation] for the recipe with the given
  /// [recipeUrlOrigin].
  ///
  /// Returns null if no [AdditionalRecipeInformation] is found.
  ///
  /// If the content of the local store is invalid, it is cleared and null is
  /// returned.
  Future<AdditionalRecipeInformation?> getAdditionalRecipeInformation(
    String recipeUrlOrigin,
  ) async {
    var store = await SharedPreferences.getInstance();
    var jsonList = store.getStringList("additional_recipe_informations");

    if (jsonList == null || jsonList.isEmpty) {
      return null;
    }

    var additionalRecipeInformations = <AdditionalRecipeInformation>[];
    for (var jsonString in jsonList) {
      try {
        additionalRecipeInformations.add(
          AdditionalRecipeInformation.fromJson(
            jsonDecode(jsonString),
          ),
        );
      } on FormatException {
        await store.remove("additional_recipe_informations");
        return null;
      }
    }

    var matches = additionalRecipeInformations.where(
      (element) => element.recipeUrlOrigin == recipeUrlOrigin,
    );

    return matches.isEmpty ? null : matches.first;
  }
}
