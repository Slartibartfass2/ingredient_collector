part of recipe_parser;

/// [RecipeParser] implementation for `mobile.kptncook.com`.
class KptnCookParser extends RecipeParser {
  /// Creates a new [KptnCookParser].
  const KptnCookParser();

  @override
  RecipeParsingResult parseRecipe(
    Document document,
    RecipeParsingJob recipeParsingJob,
  ) {
    var recipeNameElements =
        document.getElementsByClassName("kptn-recipetitle");
    var servingsElements = document.getElementsByClassName("kptn-person-count");
    var listContainers = document.getElementsByClassName("col-md-offset-3");

    // Check whether every information is provided
    if (recipeNameElements.isEmpty ||
        servingsElements.isEmpty ||
        listContainers.length < 3 ||
        listContainers[2].children.length < 3) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(
            subType: JobLogSubType.completeFailure,
            recipeUrl: recipeParsingJob.url,
          ),
        ],
      );
    }

    var recipeName = recipeNameElements.first.text.trim();

    // Retrieve amount of servings
    var servingsPattern = RegExp("[0-9]+");
    var servingsDescriptionText = servingsElements.first.text;
    var recipeServingsMatch =
        servingsPattern.firstMatch(servingsDescriptionText);
    var matchGroup = recipeServingsMatch?.group(0);
    if (matchGroup == null) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(
            subType: JobLogSubType.completeFailure,
            recipeUrl: recipeParsingJob.url,
          ),
        ],
      );
    }
    var recipeServings = num.parse(matchGroup);
    var servingsMultiplier = recipeParsingJob.servings / recipeServings;

    // Skip first two html elements which aren't ingredients
    var ingredientElements = listContainers[2].children.sublist(2);

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
  @visibleForTesting
  IngredientParsingResult parseIngredient(
    Element element,
    double servingsMultiplier,
    Uri recipeUrl,
    String? language,
  ) {
    var name = "";
    var nameElements = element.getElementsByClassName("kptn-ingredient");
    if (nameElements.isNotEmpty) {
      name = nameElements.first.text.trim();
    } else {
      return IngredientParsingResult(
        logs: [
          SimpleJobLog(
            subType: JobLogSubType.ingredientParsingFailure,
            recipeUrl: recipeUrl,
          ),
        ],
      );
    }

    var logs = <JobLog>[];

    var amount = 0.0;
    var unit = "";
    var measureElements =
        element.getElementsByClassName("kptn-ingredient-measure");
    if (measureElements.isNotEmpty) {
      var amountUnitStrings =
          measureElements.first.text.trim().split(RegExp(r"\s"));
      var amountString = amountUnitStrings.first;
      var parsedAmount = tryParseAmountString(
        amountString,
        language: language,
        decimalSeparatorLocale: "en",
      );
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

      if (amountUnitStrings.length == 2) {
        unit = amountUnitStrings[1];
      }
    }

    return IngredientParsingResult(
      ingredients: [
        Ingredient(amount: amount, unit: unit, name: name),
      ],
      logs: logs,
    );
  }
}
