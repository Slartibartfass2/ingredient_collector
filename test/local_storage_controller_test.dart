import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/local_storage_controller.dart';
import 'package:ingredient_collector/src/models/additional_recipe_information.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe_modification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  group('Test getAdditionalRecipeInformation', () {
    test(
      'When local storage is empty and getAdditionalRecipeInformation is called'
      ', then null is returned',
      () async {
        SharedPreferences.setMockInitialValues({});

        var result = await LocalStorageController()
            .getAdditionalRecipeInformation("test", "test name");

        expect(result, isNull);
      },
    );

    test(
      'When local storage contains empty additional_recipe_informations list '
      'and getAdditionalRecipeInformation is called, then null is returned',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [],
        });

        var result = await LocalStorageController()
            .getAdditionalRecipeInformation("test", "test name");

        expect(result, isNull);
      },
    );

    test(
      'When additional_recipe_informations contains additional recipe '
      'information and getAdditionalRecipeInformation is called with different '
      'name, then null is returned',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "test note",
                "recipeModification": null,
              },
            ),
          ],
        });

        var result = await LocalStorageController()
            .getAdditionalRecipeInformation("test2", "test name2");

        expect(result, isNull);
      },
    );

    test(
      'When additional_recipe_informations contains additional recipe '
      'information and getAdditionalRecipeInformation is called, then the '
      'additional recipe information is returned',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "test note",
                "recipeModification": const RecipeModification(
                  servings: 2,
                  modifiedIngredients: [
                    Ingredient(
                      amount: 34,
                      unit: "test unit",
                      name: "test name",
                    ),
                  ],
                ),
              },
            ),
          ],
        });

        var result = await LocalStorageController()
            .getAdditionalRecipeInformation("test", "test name");

        expect(result, isNotNull);
        expect(result!.recipeUrlOrigin, "test");
        expect(result.recipeName, "test name");
        expect(result.note, "test note");
        var modification = result.recipeModification!;
        expect(modification, isNotNull);
        expect(modification.servings, 2);
        expect(modification.modifiedIngredients, isNotEmpty);
        var ingredient = modification.modifiedIngredients.first;
        expect(ingredient.amount, 34);
        expect(ingredient.unit, "test unit");
        expect(ingredient.name, "test name");
      },
    );

    test(
      'When additional_recipe_informations contains invalid json string and '
      'getAdditionalRecipeInformation is called, then null is returned and the '
      'local storage is cleared',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": ["invalid json string"],
        });

        var result = await LocalStorageController()
            .getAdditionalRecipeInformation("test", "test name");

        expect(result, isNull);
        var store = await SharedPreferences.getInstance();
        expect(store.getStringList("additional_recipe_informations"), isNull);
      },
    );
  });

  group('Test setAdditionalRecipeInformation', () {
    test(
      'When local storage is empty and setAdditionalRecipeInformation is called'
      ', then the additional recipe information is saved',
      () async {
        SharedPreferences.setMockInitialValues({});

        await _addTestAdditionalRecipeInformation();
        await _expectTestAdditionalRecipeInformation();
      },
    );

    test(
      'When local storage contains empty additional_recipe_informations list '
      'and setAdditionalRecipeInformation is called, then the additional recipe'
      ' information is saved',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [],
        });

        await _addTestAdditionalRecipeInformation();
        await _expectTestAdditionalRecipeInformation();
      },
    );

    test(
      'When additional_recipe_informations contains additional recipe '
      'information and setAdditionalRecipeInformation is called with different '
      'name, then the additional recipe information is saved',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test0",
                "recipeName": "test name0",
                "note": "test note0",
                "recipeModification": null,
              },
            ),
          ],
        });

        await _addTestAdditionalRecipeInformation(suffix: "1");
        await _expectTestAdditionalRecipeInformation(amount: 2);
      },
    );

    test(
      'When additional_recipe_informations contains additional recipe '
      'information and setAdditionalRecipeInformation is called, then the '
      'additional recipe information is overwritten',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "different test note",
                "recipeModification": const RecipeModification(
                  servings: 2,
                  modifiedIngredients: [],
                ),
              },
            ),
          ],
        });

        await _addTestAdditionalRecipeInformation();
        await _expectTestAdditionalRecipeInformation();
      },
    );

    test(
      'When additional_recipe_informations contains invalid json string and '
      'setAdditionalRecipeInformation is called, then the additional recipe '
      'information is saved and the local storage is cleared',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": ["invalid json string"],
        });

        await _addTestAdditionalRecipeInformation();
        await _expectTestAdditionalRecipeInformation();
      },
    );
  });

  group('Test getRecipeNote', () {
    test(
      'When there\'s no information stored, then an empty string is returned',
      () async {
        SharedPreferences.setMockInitialValues({});

        var result =
            await LocalStorageController().getRecipeNote("test", "test name");

        expect(result, "");
      },
    );

    test(
      'When there\'s information stored, then the note is returned',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "test note",
                "recipeModification": null,
              },
            ),
          ],
        });

        var result =
            await LocalStorageController().getRecipeNote("test", "test name");

        expect(result, "test note");
      },
    );
  });

  group('Test setRecipeNote', () {
    test(
      'When there\'s no information stored, then new information is added with '
      'the given note',
      () async {
        SharedPreferences.setMockInitialValues({});

        await LocalStorageController().setRecipeNote(
          "test",
          "test name",
          "test note",
        );

        await _expectTestAdditionalRecipeInformation();
      },
    );

    test(
      'When there\'s information stored, then the note is overwritten',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "different test note",
                "recipeModification": null,
              },
            ),
          ],
        });

        await LocalStorageController().setRecipeNote(
          "test",
          "test name",
          "test note",
        );

        await _expectTestAdditionalRecipeInformation();
      },
    );
  });

  group('Test getRecipeModification', () {
    test(
      'When there\'s no information stored, then null is returned',
      () async {
        SharedPreferences.setMockInitialValues({});

        var result = await LocalStorageController()
            .getRecipeModification("test", "test name");

        expect(result, isNull);
      },
    );

    test(
      'When there\'s information stored, then the modification is returned',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "test note",
                "recipeModification": const RecipeModification(
                  servings: 2,
                  modifiedIngredients: [],
                ),
              },
            ),
          ],
        });

        var result = await LocalStorageController()
            .getRecipeModification("test", "test name");

        expect(result, isNotNull);
        expect(result!.servings, 2);
        expect(result.modifiedIngredients, isEmpty);
      },
    );
  });

  group('Test setRecipeModification', () {
    test(
      'When there\'s no information stored, then new information is added with '
      'the given modification',
      () async {
        SharedPreferences.setMockInitialValues({});

        await LocalStorageController().setRecipeModification(
          "test",
          "test name",
          const RecipeModification(
            servings: 2,
            modifiedIngredients: [],
          ),
        );

        await _expectTestAdditionalRecipeInformation(
          expectedRecipeModification: const RecipeModification(
            servings: 2,
            modifiedIngredients: [],
          ),
          isNoteEmpty: true,
        );
      },
    );

    test(
      'When there\'s information stored, then the modification is overwritten',
      () async {
        SharedPreferences.setMockInitialValues({
          "additional_recipe_informations": [
            jsonEncode(
              {
                "recipeUrlOrigin": "test",
                "recipeName": "test name",
                "note": "test note",
                "recipeModification": const RecipeModification(
                  servings: 4,
                  modifiedIngredients: [
                    Ingredient(
                      amount: 1,
                      unit: "test unit",
                      name: "test ingredient",
                    ),
                  ],
                ),
              },
            ),
          ],
        });

        await LocalStorageController().setRecipeModification(
          "test",
          "test name",
          const RecipeModification(
            servings: 2,
            modifiedIngredients: [],
          ),
        );

        await _expectTestAdditionalRecipeInformation(
          expectedRecipeModification: const RecipeModification(
            servings: 2,
            modifiedIngredients: [],
          ),
        );
      },
    );
  });
}

Future<void> _addTestAdditionalRecipeInformation({String suffix = ""}) async {
  await LocalStorageController().setAdditionalRecipeInformation(
    AdditionalRecipeInformation(
      recipeUrlOrigin: "test$suffix",
      recipeName: "test name$suffix",
      note: "test note$suffix",
      recipeModification: null,
    ),
  );
}

Future<void> _expectTestAdditionalRecipeInformation({
  int amount = 1,
  RecipeModification? expectedRecipeModification,
  bool isNoteEmpty = false,
}) async {
  var store = await SharedPreferences.getInstance();
  var jsonList = store.getStringList("additional_recipe_informations");
  expect(jsonList, isNotNull);
  expect(jsonList!.length, amount);
  for (var i = 0; i < amount; i++) {
    var additionalRecipeInformation =
        AdditionalRecipeInformation.fromJson(jsonDecode(jsonList[i]));
    expect(json, isNotNull);
    var suffix = amount == 1 ? "" : "$i";
    expect(additionalRecipeInformation.recipeUrlOrigin, "test$suffix");
    expect(additionalRecipeInformation.recipeName, "test name$suffix");
    expect(
      additionalRecipeInformation.note,
      isNoteEmpty ? "" : "test note$suffix",
    );
    expect(
      additionalRecipeInformation.recipeModification,
      equals(expectedRecipeModification),
    );
  }
}
