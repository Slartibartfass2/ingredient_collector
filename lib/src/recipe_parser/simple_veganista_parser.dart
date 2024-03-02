part of recipe_parser;

/// [RecipeParser] implementation for `simple-veganista.com`.
class SimpleVeganistaParser extends RecipeParser {
  /// Creates a new [SimpleVeganistaParser].
  const SimpleVeganistaParser();

  @override
  RecipeParsingResult parseRecipe(
    Document document,
    RecipeParsingJob recipeParsingJob,
  ) {
    var recipeNameElements =
        document.getElementsByClassName("tasty-recipes-title");
    var servingsElements = document
        .getElementsByClassName("tasty-recipes-yield")
        .map((elements) => elements.getElementsByTagName("span"))
        .expand((element) => element);
    var ingredientElements = document
        .getElementsByClassName("tasty-recipes-ingredients-body")
        .map((container) => container.getElementsByTagName("li"))
        .expand((element) => element);

    if (recipeNameElements.isEmpty ||
        servingsElements.isEmpty ||
        ingredientElements.isEmpty) {
      return RecipeParsingResult(
        metaDataLogs: [
          CompleteFailureMetaDataLog(recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var recipeName = recipeNameElements.first.text.trim();
    var recipeServings = int.parse(servingsElements.first.text);
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
  @visibleForTesting
  IngredientParsingResult parseIngredient(
    Element element,
    double servingsMultiplier,
    String recipeUrl,
    String? language,
  ) {
    var spans = element.getElementsByTagName("span");
    var amount = _parseAmount(spans);
    var unit = "";
    for (var span in spans) {
      var parsedUnit = _parseUnit(span);
      if (parsedUnit != null) {
        unit = parsedUnit;
        break;
      }
    }

    var name = element
        .getElementsByTagName("strong")
        .map((e) => e.text.trim())
        .join(" ");

    print("amount: $amount, unit: $unit, name: $name");

    return const IngredientParsingResult();
  }

  double _parseAmount(List<Element> spans) {
    var attributes = ["data-nf-metric", "data-amount"];
    for (var attribute in attributes) {
      var matching =
          spans.map((e) => e.attributes[attribute]).whereType<String>();
      if (matching.isEmpty) {
        continue;
      }
      var sum = matching
          .map(tryParseAmountString)
          .whereType<double>()
          .reduce((sum, value) => sum + value);
      return sum / matching.length;
    }
    return 0;
  }

  String? _parseUnit(Element span) {
    var attributes = ["data-nf-metric-unit", "data-unit"];
    for (var attribute in attributes) {
      var attributeValue = span.attributes[attribute];
      if (attributeValue != null) {
        return attributeValue;
      }
    }
    return null;
  }
}
