import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show KptnCookParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  test(
    "collect KptnCook recipe",
    () async {
      var recipeJob = RecipeController().createRecipeParsingJob(
        url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/4b596ab7"),
        servings: 2,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [recipeJob],
        language: "de",
      );
      expect(result.length, 1);
      expect(hasRecipeParsingErrors(result.first), isFalse);

      var recipe = result.first.recipe!;
      expect(recipe.servings, 2);
      expect(recipe.ingredients.length, 18);

      expectIngredient(recipe, "Limette", amount: 1);
      expectIngredient(recipe, "Ingwer", amount: 10, unit: "g");
      expectIngredient(recipe, "Kokosmilch", amount: 150, unit: "ml");
      expectIngredient(recipe, "Brokkoli", amount: 1);
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
    },
    tags: ["parsing-test"],
  );

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

      await testParsingRecipes(urls, language: "de");
    },
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  test('parse empty ingredient element', () {
    var parser = const KptnCookParser();
    var ingredientElement = Element.html("<a></a>");
    var result = parser.parseIngredient(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse ingredient element with amount and unit', () {
    var parser = const KptnCookParser();
    var ingredientElement = Element.html("""
    <div>
      <div class="kptn-ingredient-measure">
        30 g
      </div>
      <div class="kptn-ingredient">
        Walnusskerne
      </div>
    </div>
    """);
    var result = parser.parseIngredient(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(const Ingredient(amount: 30, unit: "g", name: "Walnusskerne")),
    );
  });

  test('parse ingredient element with amount and no unit', () {
    var parser = const KptnCookParser();
    var ingredientElement = Element.html("""
    <div>
      <div class="kptn-ingredient-measure">
        2
      </div>
      <div class="kptn-ingredient">
        Walnüsse
      </div>
    </div>
    """);
    var result = parser.parseIngredient(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(const Ingredient(amount: 2, unit: "", name: "Walnüsse")),
    );
  });

  test('provide feedback when amount parsing fails', () {
    var parser = const KptnCookParser();
    var ingredientElement = Element.html("""
    <div>
      <div class="kptn-ingredient-measure">
        measure
      </div>
      <div class="kptn-ingredient">
        Walnüsse
      </div>
    </div>
    """);
    var result = parser.parseIngredient(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse ingredient element with decimal amount', () {
    var parser = const KptnCookParser();
    var ingredientElement = Element.html("""
    <div>
      <div class="kptn-ingredient-measure">
        0.5
      </div>
      <div class="kptn-ingredient">
        Brokkoli
      </div>
    </div>
    """);
    var result = parser.parseIngredient(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(const Ingredient(amount: 0.5, unit: "", name: "Brokkoli")),
    );
  });

  test(
    'When sharing url is parsed, then url is redirected and correct recipe '
    'parsed',
    () async {
      var recipeJob = RecipeController().createRecipeParsingJob(
        url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/4b596ab7"),
        servings: 2,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [recipeJob],
        language: "de",
      );
      var recipe = result.first.recipe!;

      var redirectJob = RecipeController().createRecipeParsingJob(
        url: Uri.parse("https://sharing.kptncook.com/uSnuwfRkhsb"),
        servings: 2,
        language: "de",
      );

      var redirectResult = await RecipeController().collectRecipes(
        recipeParsingJobs: [redirectJob],
        language: "de",
      );
      var redirectRecipe = redirectResult.first.recipe!;

      expect(recipe, equals(redirectRecipe));
    },
    tags: ["parsing-test"],
  );
}
