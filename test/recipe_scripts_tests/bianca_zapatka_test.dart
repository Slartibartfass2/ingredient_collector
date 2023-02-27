import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_scripts/bianca_zapatka.dart';

import 'script_test_helper.dart';

void main() {
  test(
    'collect Bianca Zapatka recipe with ranges and fractions',
    () async {
      var recipeJob = RecipeParsingJob(
        url: Uri.parse("https://biancazapatka.com/de/blumenkohl-tikka-masala"),
        servings: 4,
      );

      var result = await collectRecipes([recipeJob], "de");
      expect(result.length, 1);
      expect(hasRecipeParsingErrors(result.first), isFalse);

      var recipe = result.first.recipe!;
      expect(recipe.servings, 4);
      expect(recipe.ingredients.length, 19);

      expectIngredient(recipe, "Öl", amount: 1.5, unit: "EL");
      expectIngredient(recipe, "Zwiebel", amount: 1);
      expectIngredient(recipe, "Blumenkohl (ca. 750g)", amount: 0.5);
      expectIngredient(recipe, "Knoblauchzehen", amount: 3.5);
      expectIngredient(recipe, "frischer Ingwer", amount: 1, unit: "TL");
      expectIngredient(recipe, "rote Linsen", amount: 75, unit: "g");
      expectIngredient(recipe, "Garam Masala", amount: 2, unit: "TL");
      expectIngredient(recipe, "Kurkuma", amount: 0.5, unit: "TL");
      expectIngredient(
        recipe,
        "gemahlener Kreuzkümmel",
        amount: 0.25,
        unit: "TL",
      );
      expectIngredient(
        recipe,
        "geräucherter Paprika oder Chili",
        amount: 0.5,
        unit: "TL",
      );
      expectIngredient(
        recipe,
        "Salz oder nach Geschmack",
        amount: 0.5,
        unit: "TL",
      );
      expectIngredient(recipe, "Agavensirup", amount: 1, unit: "EL");
      expectIngredient(recipe, "Dose Tomaten (400ml)", amount: 1);
      expectIngredient(recipe, "Gemüsebrühe", amount: 240, unit: "ml");
      expectIngredient(
        recipe,
        "Soja-Joghurt oder Kokosmilch oder Cashew-Creme",
        amount: 120,
        unit: "g",
      );
      expectIngredient(recipe, "Reis");
      expectIngredient(recipe, "geröstete Cashewnüsse");
      expectIngredient(recipe, "Sesam");
      expectIngredient(recipe, "frische Petersilie");
    },
    tags: ["parsing-test"],
  );

  test(
    'collect Bianca Zapatka recipe with fractions and doubles',
    () async {
      var recipeJob = RecipeParsingJob(
        url: Uri.parse(
          "https://biancazapatka.com/de/veganes-schlemmerfilet-bordelaise",
        ),
        servings: 2,
        language: "de",
      );

      var result = await collectRecipes([recipeJob], "de");
      expect(result.length, 1);
      expect(hasRecipeParsingErrors(result.first), isFalse);

      var recipe = result.first.recipe!;
      expect(recipe.servings, 2);
      expect(recipe.ingredients.length, 17);

      expectIngredient(recipe, "Tofu", amount: 200, unit: "g");
      expectIngredient(recipe, "Noriblatt", amount: 0.5);
      expectIngredient(recipe, "vegane Butter", amount: 60, unit: "g");
      expectIngredient(recipe, "Zwiebel", amount: 1);
      expectIngredient(recipe, "Knoblauchzehen", amount: 2);
      expectIngredient(recipe, "Paprikapulver", amount: 1.5, unit: "TL");
      expectIngredient(recipe, "Hefeflocken", amount: 2, unit: "EL");
      expectIngredient(recipe, "Panko Semmelbrösel", amount: 60, unit: "g");
      expectIngredient(
        recipe,
        "Petersilie und Dill",
        amount: 0.5,
        unit: "Bund",
      );
      expectIngredient(recipe, "Zitrone", amount: 0.5);
      expectIngredient(recipe, "Salz und Pfeffer");
      expectIngredient(recipe, "Kartoffelpüree");
      expectIngredient(recipe, "Rahmspinat");
      expectIngredient(recipe, "Vegane Hollandaise");
      expectIngredient(recipe, "Zitronenscheiben");
      expectIngredient(recipe, "Petersilie und Dill");
      expectIngredient(
        recipe,
        "NORSAN Omega-3 Vegan Öl",
        amount: 1,
        unit: "TL",
      );
    },
    tags: ["parsing-test"],
  );

  test(
    'collect many Bianca Zapatka recipes',
    () async {
      var urls = [
        "https://biancazapatka.com/de/blumenkohl-tikka-masala",
        "https://biancazapatka.com/de/veganer-shepherds-pie-mit-linsen",
        "https://biancazapatka.com/de/cremiges-pilzrisotto",
        "https://biancazapatka.com/de/kuerbis-cheesecake-brownies",
        "https://biancazapatka.com/de/gemuesenudeln-mit-erdnuss-sauce",
        "https://biancazapatka.com/de/einfache-pilz-pasta-mit-spinat-vegan",
        "https://biancazapatka.com/de/veganes-mac-and-cheese-vegane-kaesesosse",
        "https://biancazapatka.com/de/vegane-nussecken",
        "https://biancazapatka.com/de/schokoladen-kaesekuchen-rezept",
        "https://biancazapatka.com/de/reispapier-dumplings",
        "https://biancazapatka.com/de/knuspriger-tofu-asiatisch",
        "https://biancazapatka.com/de/gruenkernbratlinge",
        "https://biancazapatka.com/de/arancini-reisbaellchen",
        "https://biancazapatka.com/de/risotto-grundrezept",
        "https://biancazapatka.com/de/tom-yam-gung-suppe",
        "https://biancazapatka.com/de/chana-masala",
        "https://biancazapatka.com/de/gemuese-suess-sauer-mit-kichererbsen",
        "https://biancazapatka.com/de/vegane-frittata-mit-gemuese",
        "https://biancazapatka.com/de/kartoffel-hack-auflauf",
        "https://biancazapatka.com/de/bauerntopf",
        "https://biancazapatka.com/de/goldene-linsensuppe",
        "https://biancazapatka.com/de/veganer-zwiebelkuchen",
        "https://biancazapatka.com/de/gebratene-champignons-mit-knoblauchsosse",
        "https://biancazapatka.com/de/erdnuss-curry-mit-gemuese",
        "https://biancazapatka.com/de/vegane-haehnchenkeulen",
        "https://biancazapatka.com/de/vegane-frikadellen",
        "https://biancazapatka.com/de/knusprige-bratkartoffeln",
        "https://biancazapatka.com/de/suesskartoffel-bowl-mit-kichererbsen",
        "https://biancazapatka.com/de/veganes-schlemmerfilet-bordelaise",
        "https://biancazapatka.com/de/meine-liebste-kuerbissuppe",
        "https://biancazapatka.com/de/kuerbisbroetchen",
        "https://biancazapatka.com/de/nudelspiesse",
        "https://biancazapatka.com/de/kichererbsen-eintopf-mit-auberginen",
        "https://biancazapatka.com/de/kartoffelspiralen",
        "https://biancazapatka.com/de/rote-linsen-bratlinge",
        "https://biancazapatka.com/de/gelbes-gemuese-curry-mit-kichererbsen",
      ];

      await testParsingRecipes(urls);
    },
    tags: ["parsing-test"],
    timeout: const Timeout(Duration(minutes: 5)),
  );

  test('parse empty ingredient element', () {
    var ingredientElement = Element.html("<a></a>");
    var result = parseIngredient(ingredientElement, 1, "");
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse ingredient element with amount and unit', () {
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">ca. 24,5</span>
      <span class="wprm-recipe-ingredient-unit">ml</span>
      <span class="wprm-recipe-ingredient-name">Gemüsebrühe</span>
    </li>
    """);
    var result = parseIngredient(ingredientElement, 1, "", language: "de");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients[0],
      equals(const Ingredient(amount: 24.5, unit: "ml", name: "Gemüsebrühe")),
    );
  });

  test('parse ingredient element with amount and no unit', () {
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">½</span>
      <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
    </li>
    """);
    var result = parseIngredient(ingredientElement, 1, "");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients[0],
      equals(const Ingredient(amount: 0.5, unit: "", name: "Blumenkohl")),
    );
  });

  test('provide feedback when amount parsing fails', () {
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">amount</span>
      <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
    </li>
    """);
    var result = parseIngredient(ingredientElement, 1, "");
    expect(hasIngredientParsingErrors(result), isTrue);
  });
}
