import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/ingredient_output_generator.dart';
import 'package:ingredient_collector/src/recipe_models.dart';

void main() {
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
    expect(mergedIngredients.contains(ingredients[0]), isTrue);
    expect(mergedIngredients.contains(ingredients[1]), isTrue);
  });

  test('merge ingredients with same name but different unit', () {
    const ingredients = [
      Ingredient(amount: 200, unit: "g", name: "Sugar"),
      Ingredient(amount: 400, unit: "kg", name: "Sugar"),
    ];

    var mergedIngredients = mergeIngredients(ingredients);
    expect(mergedIngredients.length, 2);
    expect(mergedIngredients.contains(ingredients[0]), isTrue);
    expect(mergedIngredients.contains(ingredients[1]), isTrue);
  });

  test('merge ingredients with different name and unit', () {
    const ingredients = [
      Ingredient(amount: 200, unit: "g", name: "Sugar"),
      Ingredient(amount: 400, unit: "kg", name: "Flour"),
    ];

    var mergedIngredients = mergeIngredients(ingredients);
    expect(mergedIngredients.length, 2);
    expect(mergedIngredients.contains(ingredients[0]), isTrue);
    expect(mergedIngredients.contains(ingredients[1]), isTrue);
  });

  test('merge ingredients with same name and unit', () {
    const ingredients = [
      Ingredient(amount: 200, unit: "g", name: "Sugar"),
      Ingredient(amount: 400, unit: "g", name: "Sugar"),
    ];

    var mergedIngredients = mergeIngredients(ingredients);
    expect(mergedIngredients.length, 1);
    expect(mergedIngredients.contains(ingredients[0]), isFalse);
    expect(mergedIngredients.contains(ingredients[1]), isFalse);
    const expectedIngredient = Ingredient(
      amount: 600,
      unit: "g",
      name: "Sugar",
    );
    expect(mergedIngredients[0], equals(expectedIngredient));
  });
}
