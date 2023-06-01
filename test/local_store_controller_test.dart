import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/local_store_controller.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe_modification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  group('test getAdditionalRecipeInformation', () {
    test(
      'When local storage is empty and getAdditionalRecipeInformation is called'
      ', then null is returned',
      () async {
        SharedPreferences.setMockInitialValues({});

        var result =
            await LocalStoreController().getAdditionalRecipeInformation("test");

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

        var result =
            await LocalStoreController().getAdditionalRecipeInformation("test");

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
                "note": "test note",
                "recipeModification": null,
              },
            ),
          ],
        });

        var result = await LocalStoreController()
            .getAdditionalRecipeInformation("test2");

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

        var result =
            await LocalStoreController().getAdditionalRecipeInformation("test");

        expect(result, isNotNull);
        expect(result!.recipeUrlOrigin, "test");
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

        var result =
            await LocalStoreController().getAdditionalRecipeInformation("test");

        expect(result, isNull);
        var store = await SharedPreferences.getInstance();
        expect(store.getStringList("additional_recipe_informations"), isNull);
      },
    );
  });
}
