part of 'recipe_parser.dart';

/// [RecipeParser] implementation for every website using WordPress.
class WordPressParser extends RecipeParser {
  /// Creates a new [WordPressParser].
  const WordPressParser();

  @override
  RecipeParsingResult parseRecipe(Document document, RecipeParsingJob recipeParsingJob) {
    var recipeNameElements = document
        .getElementsByClassName("wprm-recipe-name")
        .map((element) => element.text.trim())
        .where((element) => element.isNotEmpty);
    var servingsElements =
        document
            .getElementsByClassName("wprm-recipe-servings")
            .map((e) => int.tryParse(e.text))
            .whereType<int>();
    var ingredientElements = document.getElementsByClassName("wprm-recipe-ingredient");

    if (recipeNameElements.isEmpty || servingsElements.isEmpty || ingredientElements.isEmpty) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(subType: JobLogSubType.completeFailure, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var recipeName = recipeNameElements.first;
    var recipeServings = servingsElements.first;
    var servingsMultiplier = recipeParsingJob.servings / recipeServings;

    return createResultFromIngredientParsing(
      ingredientElements,
      recipeParsingJob,
      servingsMultiplier,
      recipeName,
      parseIngredient,
    );
  }

  /// Parses an html [Element] representing an [Ingredient].
  ///
  /// If the parsing fails the ingredient in [IngredientParsingResult] will be
  /// null and a suitable log will be returned.
  IngredientParsingResult parseIngredient(
    Element element,
    double servingsMultiplier,
    Uri recipeUrl,
    String language,
  ) {
    var name = "";
    var nameElements = element.getElementsByClassName("wprm-recipe-ingredient-name");
    if (nameElements.isEmpty) {
      return IngredientParsingResult(
        logs: [SimpleJobLog(subType: JobLogSubType.ingredientParsingFailure, recipeUrl: recipeUrl)],
      );
    }

    var nameElement = nameElements.first;
    // Sometimes the name has a url reference in a <a> tag
    name =
        nameElement.children.isNotEmpty
            ? nameElement.children.map((element) => element.text).join().trim()
            : nameElement.text.trim();

    var logs = <JobLog>[];

    var amount = 0.0;
    var amountElements = element.getElementsByClassName("wprm-recipe-ingredient-amount");
    if (amountElements.isNotEmpty) {
      var amountElement = amountElements.first;
      var amountString = amountElement.text.trim();
      var parsedAmount = tryParseAmountString(amountString, language);
      if (parsedAmount != null) {
        amount = parsedAmount * servingsMultiplier;
      } else {
        logs.add(
          AmountParsingFailureJobLog(
            recipeUrl: recipeUrl,
            amountString: amountString,
            ingredientName: name,
          ),
        );
      }
    }

    var unit = "";
    var unitElements = element.getElementsByClassName("wprm-recipe-ingredient-unit");
    if (unitElements.isNotEmpty) {
      var unitElement = unitElements.first;
      unit = unitElement.text.trim();
    }

    return IngredientParsingResult(
      ingredients: [Ingredient(amount: amount, unit: unit, name: name)],
      logs: logs,
    );
  }
}
