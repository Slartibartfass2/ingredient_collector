import 'dart:convert';

import 'package:flutter/material.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/additional_recipe_information.dart';
import 'models/recipe_modification.dart';

/// Controller for the local storage.
///
/// The local storage is used to save [AdditionalRecipeInformation]s.
class LocalStorageController {
  /// Key for the additional recipe information in the local storage.
  static const additionalRecipeInformationKey =
      "additional_recipe_informations";

  /// Returns the note for the recipe with the given [recipeUrlOrigin] and
  /// [recipeName].
  ///
  /// Returns an empty string if no note is found.
  /// If the content of the local storage is invalid, it is cleared and an empty
  /// string is returned.
  Future<String> getRecipeNote(
    String recipeUrlOrigin,
    String recipeName,
  ) async {
    var additionalRecipeInformation =
        await getAdditionalRecipeInformation(recipeUrlOrigin, recipeName);
    return additionalRecipeInformation?.note ?? "";
  }

  /// Saves the given [note] for the recipe with the given [recipeUrlOrigin] and
  /// [recipeName] to the local storage.
  ///
  /// If the given [note] is empty, nothing is saved, otherwise it is saved.
  /// If there is already a note saved for the given recipe, it is overwritten.
  Future<void> setRecipeNote(
    String recipeUrlOrigin,
    String recipeName,
    String note,
  ) async {
    var additionalRecipeInformation =
        await getAdditionalRecipeInformation(recipeUrlOrigin, recipeName);

    additionalRecipeInformation = additionalRecipeInformation == null
        ? AdditionalRecipeInformation(
            recipeUrlOrigin: recipeUrlOrigin,
            recipeName: recipeName,
            note: note,
          )
        : additionalRecipeInformation.copyWith(note: note);

    await setAdditionalRecipeInformation(additionalRecipeInformation);
  }

  /// Returns the [RecipeModification] for the recipe with the given
  /// [recipeUrlOrigin] and [recipeName].
  ///
  /// Returns null if no [RecipeModification] is found.
  /// If the content of the local storage is invalid, it is cleared and null is
  /// returned.
  Future<RecipeModification?> getRecipeModification(
    String recipeUrlOrigin,
    String recipeName,
  ) async {
    var additionalRecipeInformation =
        await getAdditionalRecipeInformation(recipeUrlOrigin, recipeName);
    return additionalRecipeInformation?.recipeModification;
  }

  /// Saves the given [modification] for the recipe with the given
  /// [recipeUrlOrigin] and [recipeName] to the local storage.
  ///
  /// If the given [modification] is null, nothing is saved, otherwise it is
  /// saved.
  /// If there is already a modification saved for the given recipe, it is
  /// overwritten.
  Future<void> setRecipeModification(
    String recipeUrlOrigin,
    String recipeName,
    RecipeModification modification,
  ) async {
    var additionalRecipeInformation =
        await getAdditionalRecipeInformation(recipeUrlOrigin, recipeName);

    additionalRecipeInformation = additionalRecipeInformation == null
        ? AdditionalRecipeInformation(
            recipeUrlOrigin: recipeUrlOrigin,
            recipeName: recipeName,
            recipeModification: modification,
          )
        : additionalRecipeInformation.copyWith(
            recipeModification: modification,
          );
    await setAdditionalRecipeInformation(additionalRecipeInformation);
  }

  /// Returns the [AdditionalRecipeInformation] for the recipe with the given
  /// [recipeUrlOrigin] and [recipeName].
  ///
  /// Returns null if no [AdditionalRecipeInformation] is found.
  ///
  /// If the content of the local storage is invalid, it is cleared and null is
  /// returned.
  Future<AdditionalRecipeInformation?> getAdditionalRecipeInformation(
    String recipeUrlOrigin,
    String recipeName,
  ) async {
    var store = await SharedPreferences.getInstance();
    var jsonList = store.getStringList(additionalRecipeInformationKey);

    if (jsonList == null || jsonList.isEmpty) {
      return null;
    }

    var additionalRecipeInformationList = _getAdditionalRecipeInformationList(
      jsonList,
      () async {
        await store.remove(additionalRecipeInformationKey);
      },
    );

    var matches = additionalRecipeInformationList.where(
      (element) =>
          element.recipeUrlOrigin == recipeUrlOrigin &&
          element.recipeName == recipeName,
    );

    return matches.isEmpty ? null : matches.first;
  }

  /// Saves the given [additionalRecipeInformation] to the local storage.
  ///
  /// If the content of the local store is invalid, it is cleared.
  /// If the given [additionalRecipeInformation] is already saved, it is
  /// overwritten, otherwise it is added.
  @visibleForTesting
  Future<void> setAdditionalRecipeInformation(
    AdditionalRecipeInformation additionalRecipeInformation,
  ) async {
    var store = await SharedPreferences.getInstance();
    var jsonList = store.getStringList(additionalRecipeInformationKey);

    // If there was no additional recipe information saved yet, save the given
    // additional recipe information.
    if (jsonList == null || jsonList.isEmpty) {
      await store.setStringList(
        additionalRecipeInformationKey,
        [jsonEncode(additionalRecipeInformation.toJson())],
      );
      return;
    }

    var additionalRecipeInformationList = _getAdditionalRecipeInformationList(
      jsonList,
      () async {
        await store.remove(additionalRecipeInformationKey);
      },
    );

    var matches = additionalRecipeInformationList.where(
      (element) =>
          element.recipeUrlOrigin ==
              additionalRecipeInformation.recipeUrlOrigin &&
          element.recipeName == additionalRecipeInformation.recipeName,
    );

    // Overwrite the saved additional recipe information if it already exists.
    if (matches.isNotEmpty) {
      additionalRecipeInformationList.remove(matches.first);
    }

    // If the information is empty, it is not stored.
    var note = additionalRecipeInformation.note;
    var modification = additionalRecipeInformation.recipeModification;
    var isEmptyInformation = note.isEmpty &&
        (modification == null || modification.modifiedIngredients.isEmpty);
    if (!isEmptyInformation) {
      additionalRecipeInformationList.add(additionalRecipeInformation);
    }

    await store.setStringList(
      additionalRecipeInformationKey,
      additionalRecipeInformationList
          .map((e) => jsonEncode(e.toJson()))
          .toList(),
    );
  }

  List<AdditionalRecipeInformation> _getAdditionalRecipeInformationList(
    List<String> jsonList,
    void Function() onFormatException,
  ) {
    var additionalRecipeInformationList = <AdditionalRecipeInformation>[];
    for (var jsonString in jsonList) {
      try {
        additionalRecipeInformationList.add(
          AdditionalRecipeInformation.fromJson(
            jsonDecode(jsonString),
          ),
        );
      } on FormatException {
        onFormatException();
        return [];
      }
    }
    return additionalRecipeInformationList;
  }
}
