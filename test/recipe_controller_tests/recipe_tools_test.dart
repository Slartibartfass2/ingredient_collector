import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/domain/ingredient.dart';
import 'package:ingredient_collector/src/models/domain/recipe.dart';
import 'package:ingredient_collector/src/models/local_storage/recipe_modification.dart';
import 'package:ingredient_collector/src/models/parsing/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_tools.dart';

void main() {
  group('Test mergeRecipePrasingJobs', () {
    test('When empty list is merged, then an empty list is returned', () {
      var mergedJobs = mergeRecipeParsingJobs([]);
      expect(mergedJobs, isEmpty);
    });

    test(
      'When list with no duplicates is merged, then equal list is returned',
      () {
        var jobs = [
          RecipeParsingJob(id: 0, url: Uri.parse("url1"), servings: 1),
          RecipeParsingJob(id: 0, url: Uri.parse("url2"), servings: 2),
          RecipeParsingJob(id: 0, url: Uri.parse("url3"), servings: 3),
        ];
        var mergedJobs = mergeRecipeParsingJobs(jobs);
        expect(mergedJobs, equals(jobs));
      },
    );

    test(
      'When duplicates are merged, then duplicates result in one job',
      () {
        var jobs = [
          RecipeParsingJob(id: 0, url: Uri.parse("url1"), servings: 1),
          RecipeParsingJob(id: 0, url: Uri.parse("url2"), servings: 2),
          RecipeParsingJob(id: 0, url: Uri.parse("url1"), servings: 3),
        ];
        var mergedJobs = mergeRecipeParsingJobs(jobs);
        expect(
          mergedJobs,
          equals([
            RecipeParsingJob(id: 0, url: Uri.parse("url1"), servings: 4),
            RecipeParsingJob(id: 0, url: Uri.parse("url2"), servings: 2),
          ]),
        );
      },
    );
  });

  group('Test modifyRecipe', () {
    test('When recipe is modified, then modification is applied', () {
      var recipe = const Recipe(
        ingredients: [
          Ingredient(amount: 1, unit: "g", name: "Salz"),
          Ingredient(amount: 3, unit: "kg", name: "Mehl"),
          Ingredient(amount: 2, unit: "", name: "Gurken"),
          Ingredient(amount: 5, unit: "", name: "Erdbeeren"),
        ],
        name: "Test Recipe",
        servings: 4,
      );

      var modification = const RecipeModification(
        servings: 2,
        modifiedIngredients: [
          Ingredient(amount: 2, unit: "g", name: "Salz"),
          Ingredient(amount: 1, unit: "g", name: "Mehl"),
          Ingredient(amount: 7, unit: "", name: "Erdbeeren"),
          Ingredient(amount: 1, unit: "", name: "Glas"),
        ],
      );

      var modifiedRecipe = modifyRecipe(
        recipe: recipe,
        modification: modification,
      );

      expect(modifiedRecipe.name, "Test Recipe");
      expect(modifiedRecipe.servings, 4);
      expect(modifiedRecipe.ingredients.length, 5);

      var expectedIngredients = [
        const Ingredient(amount: 4, unit: "g", name: "Salz"),
        const Ingredient(amount: 2, unit: "g", name: "Mehl"),
        const Ingredient(amount: 2, unit: "", name: "Gurken"),
        const Ingredient(amount: 14, unit: "", name: "Erdbeeren"),
        const Ingredient(amount: 2, unit: "", name: "Glas"),
      ];

      for (var ingredient in modifiedRecipe.ingredients) {
        expect(expectedIngredients.contains(ingredient), isTrue);
      }
    });

    test(
      'When modification contains ingredient with negative amount, then the '
      'ingredient is removed from the recipe',
      () {
        var recipe = const Recipe(
          ingredients: [
            Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
          ],
          name: "Test Recipe",
          servings: 2,
        );

        var modification = const RecipeModification(
          servings: 4,
          modifiedIngredients: [
            Ingredient(amount: -1, unit: "kg", name: "Test Ingredient"),
          ],
        );

        var modifiedRecipe = modifyRecipe(
          recipe: recipe,
          modification: modification,
        );

        expect(modifiedRecipe.name, "Test Recipe");
        expect(modifiedRecipe.servings, 2);
        expect(modifiedRecipe.ingredients, isEmpty);
      },
    );

    test(
      'When the modifications contains new ingredients, then they are added to '
      'the recipe',
      () {
        var recipe = const Recipe(
          ingredients: [
            Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
          ],
          name: "Test Recipe",
          servings: 2,
        );

        var modification = const RecipeModification(
          servings: 4,
          modifiedIngredients: [
            Ingredient(amount: 10, unit: "kg", name: "Test Ingredient"),
            Ingredient(amount: 1, unit: "kg", name: "New Ingredient"),
          ],
        );

        var modifiedRecipe = modifyRecipe(
          recipe: recipe,
          modification: modification,
        );

        expect(modifiedRecipe.name, "Test Recipe");
        expect(modifiedRecipe.servings, 2);
        expect(modifiedRecipe.ingredients.length, 2);
        var ingredient = modifiedRecipe.ingredients.first;
        expect(ingredient.name, "Test Ingredient");
        expect(ingredient.amount, 5);
        expect(ingredient.unit, "kg");
        ingredient = modifiedRecipe.ingredients.last;
        expect(ingredient.name, "New Ingredient");
        expect(ingredient.amount, 0.5);
        expect(ingredient.unit, "kg");
      },
    );
  });

  group('Test mergeIngredients', () {
    test('merge ingredients with empty list', () {
      var mergedIngredients = mergeIngredients([]);
      expect(mergedIngredients, isEmpty);
    });

    test('merge ingredients with same unit but different names', () {
      const ingredients = [
        Ingredient(amount: 200, unit: "g", name: "Sugar"),
        Ingredient(amount: 400, unit: "g", name: "Flour"),
      ];

      var mergedIngredients = mergeIngredients(ingredients);
      expect(mergedIngredients.length, 2);
      expect(mergedIngredients.contains(ingredients.first), isTrue);
      expect(mergedIngredients.contains(ingredients[1]), isTrue);
    });

    test('merge ingredients with same name but different unit', () {
      const ingredients = [
        Ingredient(amount: 200, unit: "g", name: "Sugar"),
        Ingredient(amount: 400, unit: "kg", name: "Sugar"),
      ];

      var mergedIngredients = mergeIngredients(ingredients);
      expect(mergedIngredients.length, 2);
      expect(mergedIngredients.contains(ingredients.first), isTrue);
      expect(mergedIngredients.contains(ingredients[1]), isTrue);
    });

    test('merge ingredients with different name and unit', () {
      const ingredients = [
        Ingredient(amount: 200, unit: "g", name: "Sugar"),
        Ingredient(amount: 400, unit: "kg", name: "Flour"),
      ];

      var mergedIngredients = mergeIngredients(ingredients);
      expect(mergedIngredients.length, 2);
      expect(mergedIngredients.contains(ingredients.first), isTrue);
      expect(mergedIngredients.contains(ingredients[1]), isTrue);
    });

    test('merge ingredients with same name and unit', () {
      const ingredients = [
        Ingredient(amount: 200, unit: "g", name: "Sugar"),
        Ingredient(amount: 400, unit: "g", name: "Sugar"),
      ];

      var mergedIngredients = mergeIngredients(ingredients);
      expect(mergedIngredients.length, 1);
      expect(mergedIngredients.contains(ingredients.first), isFalse);
      expect(mergedIngredients.contains(ingredients[1]), isFalse);
      const expectedIngredient = Ingredient(
        amount: 600,
        unit: "g",
        name: "Sugar",
      );
      expect(mergedIngredients.first, equals(expectedIngredient));
    });
  });

  group('Test getModification', () {
    test(
      'When getModification is called, then a correct RecipeModification is '
      'created',
      () {
        var modifiedIngredients = [
          const Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
          const Ingredient(amount: 10, unit: "kg", name: "Test Ingredient 2"),
        ];

        var removedIngredients = [
          const Ingredient(amount: 1, unit: "g", name: "Test Ingredient 3"),
          const Ingredient(amount: 10, unit: "kg", name: "Test Ingredient 4"),
        ];

        var modification = getModification(
          servings: 4,
          modifiedIngredients: modifiedIngredients,
          removedIngredients: removedIngredients,
        );

        expect(modification.servings, 4);
        expect(modification.modifiedIngredients.length, 4);

        var expectedIngredients = [
          const Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
          const Ingredient(amount: 10, unit: "kg", name: "Test Ingredient 2"),
          const Ingredient(amount: -1, unit: "g", name: "Test Ingredient 3"),
          const Ingredient(amount: -1, unit: "kg", name: "Test Ingredient 4"),
        ];

        for (var ingredient in modification.modifiedIngredients) {
          expect(expectedIngredients.contains(ingredient), isTrue);
        }
      },
    );
  });
}
