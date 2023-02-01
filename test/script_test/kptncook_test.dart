import 'package:flutter_test/flutter_test.dart' show test, expect;
import 'package:ingredient_collector/src/recipe_controller.dart'
    show collectRecipes;
import 'package:ingredient_collector/src/recipe_models.dart' show RecipeInfo;

import 'script_test_helper.dart' show expectIngredient;

void main() {
  test("collect KptnCook recipe", () async {
    var recipeInfos = [
      RecipeInfo(
        url: Uri.parse(
          "http://mobile.kptncook.com/recipe/pinterest/4b596ab7",
        ),
        servings: 2,
      ),
    ];

    var result = await collectRecipes(recipeInfos: recipeInfos, language: "de");
    expect(result.length, 1);

    var recipe = result.first;
    expect(recipe.servings, 2);
    expect(recipe.ingredients.length, 18);

    expectIngredient(recipe, "Limette", amount: 1);
    expectIngredient(recipe, "Ingwer", amount: 10, unit: "g");
    expectIngredient(recipe, "Kokosmilch", amount: 150, unit: "ml");
    expectIngredient(recipe, "Brokkoli", amount: 0.5);
    expectIngredient(recipe, "Koriander, frisch", amount: 10, unit: "g");
    expectIngredient(recipe, "Basmati-Reis", amount: 120, unit: "g");
    expectIngredient(recipe, "Räuchertofu", amount: 200, unit: "g");
    expectIngredient(recipe, "Sesamsaat", amount: 10, unit: "g");
    expectIngredient(recipe, "Sonnenblumenöl");
    expectIngredient(recipe, "Sojasauce");
    expectIngredient(recipe, "Knoblauch");
    expectIngredient(recipe, "Sesamöl");
    expectIngredient(recipe, "Weißweinessig");
    expectIngredient(recipe, "Salz");
    expectIngredient(recipe, "Agavendicksaft");
    expectIngredient(recipe, "Wasser");
    expectIngredient(recipe, "Chiliflocken");
    expectIngredient(recipe, "Speisestärke");
  });
}
