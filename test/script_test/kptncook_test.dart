import 'package:flutter_test/flutter_test.dart' show test, expect, fail;
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller.dart'
    show collectRecipes;

import 'script_test_helper.dart' show expectIngredient;

void main() {
  test("collect KptnCook recipe", () async {
    var recipeInfo = RecipeParsingJob(
      url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/4b596ab7"),
      servings: 2,
    );

    var result = await collectRecipes([recipeInfo], "de");
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

  test(
    "collect many KptnCook recipes",
    () async {
      var urls = [
        "http://mobile.kptncook.com/recipe/pinterest/4b596ab7",
        "http://mobile.kptncook.com/recipe/pinterest/635c0bad",
        "http://mobile.kptncook.com/recipe/pinterest/5bd47a18",
        "http://mobile.kptncook.com/recipe/pinterest/11ac751d",
        "http://mobile.kptncook.com/recipe/pinterest/246835ce",
        "http://mobile.kptncook.com/recipe/pinterest/39ca1693",
        "http://mobile.kptncook.com/recipe/pinterest/78953c30",
        "http://mobile.kptncook.com/recipe/pinterest/17a4b8b",
        "http://mobile.kptncook.com/recipe/pinterest/46bf80cc",
        "http://mobile.kptncook.com/recipe/pinterest/4fcb5947",
        "http://mobile.kptncook.com/recipe/pinterest/50d87d41",
        "http://mobile.kptncook.com/recipe/pinterest/40b423c2",
        "http://mobile.kptncook.com/recipe/pinterest/55f38392",
        "http://mobile.kptncook.com/recipe/pinterest/3d0f129a",
        "http://mobile.kptncook.com/recipe/pinterest/6894d139",
        "http://mobile.kptncook.com/recipe/pinterest/54edf8a0",
        "http://mobile.kptncook.com/recipe/pinterest/7c06707e",
        "http://mobile.kptncook.com/recipe/pinterest/304b2dc9",
        "http://mobile.kptncook.com/recipe/pinterest/3fb20708",
        "http://mobile.kptncook.com/recipe/pinterest/5a948e36",
        "http://mobile.kptncook.com/recipe/pinterest/5050d37a",
        "http://mobile.kptncook.com/recipe/pinterest/5f1565c5",
        "http://mobile.kptncook.com/recipe/pinterest/3e110959",
        "http://mobile.kptncook.com/recipe/pinterest/6a9c6549",
        "http://mobile.kptncook.com/recipe/pinterest/49219eeb",
        "http://mobile.kptncook.com/recipe/pinterest/28a3f65e",
        "http://mobile.kptncook.com/recipe/pinterest/bb082a7",
        "http://mobile.kptncook.com/recipe/pinterest/67cc5e4d",
        "http://mobile.kptncook.com/recipe/pinterest/3ac1047b",
        "http://mobile.kptncook.com/recipe/pinterest/73c683de",
        "http://mobile.kptncook.com/recipe/pinterest/1784377d",
        "http://mobile.kptncook.com/recipe/pinterest/6c44cc1f",
        "http://mobile.kptncook.com/recipe/pinterest/68af7559",
        "http://mobile.kptncook.com/recipe/pinterest/37653916",
        "http://mobile.kptncook.com/recipe/pinterest/14f40c59",
        "http://mobile.kptncook.com/recipe/pinterest/15e9a06f",
      ];

      var notWorkingUrls = <String>[];
      for (var url in urls) {
        var recipeInfo = RecipeParsingJob(url: Uri.parse(url), servings: 2);
        var result = await collectRecipes([recipeInfo], "de");
        if (result.isEmpty) {
          notWorkingUrls.add(url);
        }
      }

      if (notWorkingUrls.isNotEmpty) {
        var output = notWorkingUrls.fold(
          "The following recipes couldn't be parsed:\n",
          (string, url) => string += "- $url\n",
        );
        fail(output);
      }
    },
    tags: ["explicit", "parsing-test"],
  );
}
