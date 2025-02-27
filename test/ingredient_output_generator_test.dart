import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/ingredient_output_generator.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/output_format.dart';
import 'package:ingredient_collector/src/models/recipe.dart';

void main() {
  test('create collection result with empty list of recipes', () {
    var result = createCollectionResultFromRecipes([]);
    for (var output in result.outputFormats.values) {
      expect(output, isEmpty);
    }
  });

  test('create collection result with single recipe', () {
    var recipe = const Recipe(
      ingredients: [
        Ingredient(amount: 0, unit: "", name: "Water"),
        Ingredient(amount: 100, unit: "g", name: "Salt"),
        Ingredient(amount: 200, unit: "g", name: "Salt"),
        Ingredient(amount: 2, unit: "", name: "Apples"),
      ],
      name: "Test recipe",
      servings: 2,
    );
    var result = createCollectionResultFromRecipes([recipe]);
    for (var MapEntry(:key, :value) in result.outputFormats.entries) {
      switch (key) {
        case OutputFormat.plaintext:
          expect(value, equals("300 g Salt\n2 Apples\nWater"));
          break;
        case OutputFormat.markdown:
          expect(
            value,
            equals(
              "- [ ] 300 g Salt\n"
              "- [ ] 2 Apples\n"
              "- [ ] Water",
            ),
          );
          break;
      }
    }
  });

  test('create collection result with many recipes', () {
    var recipes = [
      const Recipe(
        ingredients: [
          Ingredient(amount: 0, unit: "", name: "Water"),
          Ingredient(amount: 100, unit: "g", name: "Salt"),
          Ingredient(amount: 200, unit: "g", name: "Salt"),
          Ingredient(amount: 2, unit: "", name: "Apples"),
        ],
        name: "Test recipe 1",
        servings: 2,
      ),
      const Recipe(
        ingredients: [
          Ingredient(amount: 300, unit: "ml", name: "Water"),
          Ingredient(amount: 500, unit: "g", name: "Sugar"),
          Ingredient(amount: 3, unit: "", name: "Tomatoes"),
        ],
        name: "Test recipe 2",
        servings: 2,
      ),
      const Recipe(
        ingredients: [
          Ingredient(amount: 0, unit: "", name: "Pepper"),
          Ingredient(amount: 0, unit: "", name: "Salt"),
          Ingredient(amount: 250, unit: "g", name: "Flour"),
          Ingredient(amount: 5, unit: "", name: "Potatoes"),
        ],
        name: "Test recipe 3",
        servings: 2,
      ),
    ];
    var result = createCollectionResultFromRecipes(recipes);
    for (var MapEntry(:key, :value) in result.outputFormats.entries) {
      switch (key) {
        case OutputFormat.plaintext:
          expect(
            value,
            equals(
              "500 g Sugar\n"
              "300 g Salt\n"
              "300 ml Water\n"
              "250 g Flour\n"
              "5 Potatoes\n"
              "3 Tomatoes\n"
              "2 Apples\n"
              "Water\n"
              "Pepper\n"
              "Salt",
            ),
          );
          break;
        case OutputFormat.markdown:
          expect(
            value,
            equals(
              "- [ ] 500 g Sugar\n"
              "- [ ] 300 g Salt\n"
              "- [ ] 300 ml Water\n"
              "- [ ] 250 g Flour\n"
              "- [ ] 5 Potatoes\n"
              "- [ ] 3 Tomatoes\n"
              "- [ ] 2 Apples\n"
              "- [ ] Water\n"
              "- [ ] Pepper\n"
              "- [ ] Salt",
            ),
          );
          break;
      }
    }
  });
}
