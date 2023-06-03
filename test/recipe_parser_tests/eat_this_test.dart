import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/l10n/locale_keys.g.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show EatThisParser;

import 'script_test_helper.dart';

void main() {
  setUp(() => RecipeCache().cache.clear());

  test(
    'collect new Eat this! recipe',
    () async {
      var recipeJob = RecipeParsingJob(
        url: Uri.parse(
          "https://www.eat-this.org/planetary-health-bowl-mit-lupinen-und-kurkuma-dressing/",
        ),
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
      expect(recipe.ingredients.length, 23);

      expectIngredient(recipe, "Sonnenblumenkerne", amount: 60, unit: "g");
      expectIngredient(recipe, "Zitrone", amount: 0.5);
      expectIngredient(recipe, "Kurkumapulver", amount: 1.5, unit: "TL");
      expectIngredient(recipe, "Ingwerpulver", amount: 1.5, unit: "TL");
      expectIngredient(recipe, "Apfelessig", amount: 2, unit: "EL");
      expectIngredient(recipe, "Apfeldicksaft", amount: 1.5, unit: "TL");
      expectIngredient(recipe, "Salz", amount: 1, unit: "TL");
      expectIngredient(recipe, "Schalotte", amount: 1);
      expectIngredient(recipe, "Rote Bete", amount: 150, unit: "g");
      expectIngredient(recipe, "Karotte", amount: 120, unit: "g");
      expectIngredient(recipe, "Apfel", amount: 60, unit: "g");
      expectIngredient(recipe, "Leinöl", amount: 1.5, unit: "EL");
      expectIngredient(recipe, "Apfelessig", amount: 1, unit: "EL");
      expectIngredient(recipe, "Pastinake", amount: 250, unit: "g");
      expectIngredient(recipe, "braune Champignons", amount: 250, unit: "g");
      expectIngredient(recipe, "Rapsöl", amount: 2, unit: "EL");
      expectIngredient(recipe, "Salz", amount: 0.75, unit: "TL");
      expectIngredient(recipe, "Buchweizen", amount: 125, unit: "g");
      expectIngredient(recipe, "Feldsalat", amount: 100, unit: "g");
      expectIngredient(recipe, "gekochte Lupinen", amount: 200, unit: "g");
      expectIngredient(recipe, "Sauerkraut", amount: 60, unit: "g");
      expectIngredient(recipe, "Walnüsse", amount: 25, unit: "g");
      expectIngredient(recipe, "Microgreens", amount: 20, unit: "g");
    },
    tags: ["parsing-test"],
  );

  test(
    'collect old Eat this! recipe',
    () async {
      var recipeJob = RecipeParsingJob(
        url: Uri.parse(
          "https://www.eat-this.org/gruner-bohnensalat-mit-speck/",
        ),
        servings: 4,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [recipeJob],
        language: "de",
      );
      expect(result.length, 1);
      expect(hasRecipeParsingErrors(result.first), isFalse);

      var recipe = result.first.recipe!;
      expect(recipe.servings, 4);
      expect(recipe.ingredients.length, 14);

      expectIngredient(recipe, "grüne Buschbohnen", amount: 750, unit: "g");
      expectIngredient(recipe, "Räuchertofu", amount: 400, unit: "g");
      expectIngredient(recipe, "Frühlingszwiebeln", amount: 2.5);
      expectIngredient(recipe, "Tomaten", amount: 2);
      expectIngredient(recipe, "Öl zum anbraten", amount: 1, unit: "EL");
      expectIngredient(recipe, "Sonnenblumenöl", amount: 4, unit: "EL");
      expectIngredient(recipe, "würziger Essig", amount: 4, unit: "EL");
      expectIngredient(recipe, "Zitronensaft", amount: 1, unit: "EL");
      expectIngredient(recipe, "Sojasauce", amount: 1, unit: "EL");
      expectIngredient(recipe, "Agavendicksaft", amount: 1, unit: "EL");
      expectIngredient(recipe, "Zucker", amount: 1, unit: "EL");
      expectIngredient(recipe, "Knoblauchzehe", amount: 1);
      expectIngredient(recipe, "Salz");
      expectIngredient(recipe, "Pfeffer, wie immer");
    },
    tags: ["parsing-test"],
  );

  test(
    'collect unsupported Eat this! recipe',
    () async {
      var recipeJob = RecipeParsingJob(
        url: Uri.parse(
          "https://www.eat-this.org/veganes-raclette/",
        ),
        servings: 4,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [recipeJob],
        language: "de",
      );
      expect(result.length, 1);
      expect(hasRecipeParsingErrors(result.first), isTrue);
      expect(
        result.first.metaDataLogs.any(
          (log) =>
              log.title ==
              LocaleKeys.parsing_messages_deliberately_unsupported_url_title,
        ),
        isTrue,
      );
    },
    tags: ["parsing-test"],
  );

  test(
    'collect many new Eat this! recipes',
    () async {
      await testParsingRecipes(_testUrlsNewRecipes, language: "de");
    },
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  test(
    'collect many old Eat this! recipes',
    () async {
      await testParsingRecipes(_testUrlsOldRecipes, language: "de");
    },
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  test('parse empty ingredient element new design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("<a></a>");
    var result =
        parser.parseIngredientNewDesign(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse empty ingredient element old design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("<a></a>");
    var result =
        parser.parseIngredientOldDesign(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse ingredient element new design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">½</span>
      <span class="wprm-recipe-ingredient-unit">TL</span>
      <span class="wprm-recipe-ingredient-name">Zucker</span>
    </li>
    """);
    var result =
        parser.parseIngredientNewDesign(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(
        const Ingredient(
          amount: 0.5,
          unit: "TL",
          name: "Zucker",
        ),
      ),
    );
  });

  test('parse ingredient element old design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("""
    <li>
      1 1/2 EL Reis- oder Ahornsirup
    </li>
    """);
    var result =
        parser.parseIngredientOldDesign(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(
        const Ingredient(
          amount: 1.5,
          unit: "EL",
          name: "Reis- oder Ahornsirup",
        ),
      ),
    );
  });

  test('provide feedback when amount parsing fails', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">amount</span>
      <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
    </li>
    """);
    var result =
        parser.parseIngredientNewDesign(ingredientElement, 1, "", "de");
    expect(hasIngredientParsingErrors(result), isTrue);
  });
}

const _testUrlsNewRecipes = <String>[
  "https://www.eat-this.org/veganer-borschtsch/",
  "https://www.eat-this.org/veganer-colcannon-irischer-kartoffelbrei/",
  "https://www.eat-this.org/vegane-karotten-brokkoli-quiche/",
  "https://www.eat-this.org/vegane-wuerstchen-im-schlafrock/",
  "https://www.eat-this.org/szechuan-pilz-scallops-in-knoblauch-sauce/",
  "https://www.eat-this.org/schwarzwurzelgemuese-mit-geroesteten-pinienkernen/",
  "https://www.eat-this.org/blaetterteig-canapes-mit-karamellisierten-zwiebeln/",
  "https://www.eat-this.org/herzhaftes-monkey-bread-mit-sauerteig/",
  "https://www.eat-this.org/vegane-chocolate-chip-cookies/",
  "https://www.eat-this.org/veganes-focaccia-mit-kirschtomaten-oliven-und-getrockneten-feigen/",
  "https://www.eat-this.org/sommerliche-regenbogen-gemueselasagne/",
  "https://www.eat-this.org/vegane-after-eight-eiscreme/",
  "https://www.eat-this.org/pinke-radieschen-gazpacho-mit-mandeln/",
  "https://www.eat-this.org/veganer-heidelbeerkuchen-mit-streuseln/",
  "https://www.eat-this.org/chinesische-fruehlingszwiebel-pancakes/",
  "https://www.eat-this.org/erdnusscurry-mit-geroesteten-auberginen/",
  "https://www.eat-this.org/veganes-heidelbeer-semifreddo/",
  "https://www.eat-this.org/blaetterteig-tomaten-galette/",
  "https://www.eat-this.org/no-food-waste-radieschensalat/",
  "https://www.eat-this.org/karottensuppe-mit-weissen-bohnen-und-zatar/",
  "https://www.eat-this.org/vegane-sesamnudeln-mit-spargel-und-pilzen/",
  "https://www.eat-this.org/chapatis-mit-vollkornmehl/",
  "https://www.eat-this.org/punjabi-chana-masala/",
  "https://www.eat-this.org/loaded-hummus-mit-geroestetem-blumenkohl/",
  "https://www.eat-this.org/curry-kokos-linsensuppe-mit-spinat/",
  "https://www.eat-this.org/veganer-gin-sour-mit-mandarine-und-zimt/",
  "https://www.eat-this.org/buchweizen-blinis-mit-rote-bete-meerrettich-creme-gin-karottenlachs/",
  "https://www.eat-this.org/veganer-quarkstollen-mit-dattel-marzipan/",
  "https://www.eat-this.org/knusprige-potato-cakes-mit-pilzfuellung-frischem-dill/",
  "https://www.eat-this.org/tempeh-selber-machen/",
  "https://www.eat-this.org/rote-bete-pasta-from-hell/",
  "https://www.eat-this.org/tofu-palak-paneer/",
  "https://www.eat-this.org/veganer-rhabarber-erdbeer-crumble-mit-vanillesauce/",
  "https://www.eat-this.org/vegane-vanillesauce/",
  "https://www.eat-this.org/blumenkohl-taboule-mit-rotkraut-geroesteten-kichererbsen/",
  "https://www.eat-this.org/ribollita-toskanische-gemuesesuppe-mit-schwarzkohl-fenchel/",
  "https://www.eat-this.org/die-besten-veganen-crepes/",
  "https://www.eat-this.org/mutabbal-orientalischer-auberginen-dip/",
  "https://www.eat-this.org/vegane-nicecream-leckeres-gesundes-eis-in-5-minuten/",
  "https://www.eat-this.org/porridge-mit-braunem-reis-karamellisierten-zimtbananen/",
  "https://www.eat-this.org/veganes-kaesefondue/",
  "https://www.eat-this.org/suesskartoffel-quinoa-sushi-mit-rote-bete-und-feldsalat/",
  "https://www.eat-this.org/fettuccine-mit-austernpilzen-thymian/",
  "https://www.eat-this.org/veganer-masala-chai/",
  "https://www.eat-this.org/kartoffel-quinoa-patties/",
  "https://www.eat-this.org/einfache-fruehstuecksmuffins/",
  "https://www.eat-this.org/buchweizen-porridge-mit-kardamom-aprikosensauce/",
  "https://www.eat-this.org/vegane-mousse-au-chocolat/",
  "https://www.eat-this.org/geroesteter-roter-rosenkohl-mit-zitrone-und-knoblauch/",
  "https://www.eat-this.org/taboule/",
];

const _testUrlsOldRecipes = <String>[
  "https://www.eat-this.org/kuerbispizza-mit-radicchio-und-granatapfel-aus-dem-uuni/",
  "https://www.eat-this.org/vegane-dinkel-laugenstangen-mit-vollkorn/",
  "https://www.eat-this.org/camping-chili-mit-dreierlei-bohnen-kaffee/",
  "https://www.eat-this.org/hummus-wrap-der-perfekte-lunch-snack/",
  "https://www.eat-this.org/vegane-quark-beerentorte-ohne-backen/",
  "https://www.eat-this.org/kamut-griessbrei-mit-sommerbeeren/",
  "https://www.eat-this.org/gegrillte-zucchinipaeckchen-mit-dinkelhack/",
  "https://www.eat-this.org/green-bean-fries-aus-dem-ofen/",
  "https://www.eat-this.org/vollkornsandwich-mit-kurkuma-currysalat-24h-in-antwerpen/",
  "https://www.eat-this.org/bunte-kartoffeln-mit-mandel-petersilien-pesto/",
  "https://www.eat-this.org/kurkuma-curry/",
  "https://www.eat-this.org/good-life-bowl-mit-ofengemuese-kurkumadressing/",
  "https://www.eat-this.org/hefezopf-mit-nussfuellung/",
  "https://www.eat-this.org/haselnuss-cupcakes-mit-feigen/",
  "https://www.eat-this.org/kuerbis-donuts-fuer-halloween-schaurige-filmtipps/",
  "https://www.eat-this.org/rote-bete-farro-bowl-mit-schwarzer-pfeffer-dressing/",
  "https://www.eat-this.org/superfood-popsicles-mit-himbeere-chia/",
  "https://www.eat-this.org/bester-after-workout-shake/",
  "https://www.eat-this.org/fruchtige-chili-gazpacho/",
  "https://www.eat-this.org/gruener-spargel-in-leichter-tomatensauce-auf-algen-pasta/",
  "https://www.eat-this.org/pizza-mit-sommergemuese-auf-glutenfreier-blumenkohl-crust/",
  "https://www.eat-this.org/holundersirup-mit-agavendicksaft/",
  "https://www.eat-this.org/vanille-rhabarberkompott-mit-kardamom/",
  "https://www.eat-this.org/leichte-fruehlingssuppe-mit-spargel-baerlauch/",
  "https://www.eat-this.org/puy-linsen/",
  "https://www.eat-this.org/quinoa-detox-bowl-mit-spinat-hummus/",
  "https://www.eat-this.org/barbecue-tofu-sandwich/",
  "https://www.eat-this.org/vegane-burrito-bowl/",
  "https://www.eat-this.org/death-chocolate-raw-chocolate-cake/",
  "https://www.eat-this.org/detox-lemonade/",
  "https://www.eat-this.org/mini-tarte-flambees/",
  "https://www.eat-this.org/cremige-lauchsuppe/",
  "https://www.eat-this.org/fusilli-mit-kuerbis-spinat-ragout/",
  "https://www.eat-this.org/cashew-kaese-dip/",
  "https://www.eat-this.org/geroestete-kichererbsen/",
  "https://www.eat-this.org/breakfast-sandwich/",
  "https://www.eat-this.org/wassermelonen-slush/",
  "https://www.eat-this.org/pastasalat-mit-conchiglioni-und-geduenstetem-gemuese/",
  "https://www.eat-this.org/carrot-cake-mit-cashew-lemon-frosting/",
  "https://www.eat-this.org/makkaroni-mit-ingwer-zitronen-marinara/",
  "https://www.eat-this.org/veggie-tray-bake/",
  "https://www.eat-this.org/vanilleeis-rhabarberkompott/",
  "https://www.eat-this.org/tagliatelle-mit-grunem-spargel-thai-basilikum-pesto/",
  "https://www.eat-this.org/st-paddys-stew/",
  "https://www.eat-this.org/crunchy-leinsamen-cracker/",
  "https://www.eat-this.org/veggie-curry-mit-kichererbsenkuchlein/",
  "https://www.eat-this.org/tuerkische-linsensuppe/",
  "https://www.eat-this.org/marble-cake-muffins/",
  "https://www.eat-this.org/last-minute-silvester-glasnudelsalat/",
  "https://www.eat-this.org/tomaten-gruenkernsuppe/",
];
