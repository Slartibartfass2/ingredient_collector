part of 'recipe_parser.dart';

/// Recipe Metadata consisting of the recipe names elements, servings elements,
/// and ingredients elements.
typedef RecipeMetadata = (Iterable<Element>, Iterable<Element>, Iterable<Element>);

/// [RecipeParser] implementation for `www.chefkoch.de`.
class ChefkochParser extends RecipeParser {
  /// Creates a new [ChefkochParser].
  const ChefkochParser();

  @override
  RecipeParsingResult parseRecipe(Document document, RecipeParsingJob recipeParsingJob) {
    var oldRecipeHeaders = document.getElementsByClassName("recipe-header");
    var isOldDesign = oldRecipeHeaders.isNotEmpty;

    var recipeNameElements = Iterable<Element>.empty();
    var servingElements = Iterable<Element>.empty();
    var ingredientElements = Iterable<Element>.empty();

    if (isOldDesign) {
      (recipeNameElements, servingElements, ingredientElements) = _parseMetaDataOld(document);
    } else {
      (recipeNameElements, servingElements, ingredientElements) = _parseMetaDataNew(document);
    }

    if (recipeNameElements.isEmpty || servingElements.isEmpty || ingredientElements.isEmpty) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(subType: JobLogSubType.completeFailure, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var recipeName = recipeNameElements.first.text.trim();
    var recipeServings = int.parse(servingElements.first.attributes["value"] ?? "");
    var servingsMultiplier = recipeParsingJob.servings / recipeServings;

    return createResultFromIngredientParsing(
      ingredientElements.toList(),
      recipeParsingJob,
      servingsMultiplier,
      recipeName,
      parseIngredient,
    );
  }

  RecipeMetadata _parseMetaDataOld(Document document) {
    var recipeNameElements = document
        .getElementsByClassName("recipe-header")
        .map((e) => e.getElementsByTagName("h1"))
        .expand((element) => element);
    var servingElements = document
        .getElementsByClassName("recipe-servings")
        .map((e) => e.getElementsByTagName("input"))
        .expand((element) => element)
        .where(_hasIntValueAttribute);
    var ingredientElements = document
        .getElementsByClassName("ingredients")
        .map((e) => e.getElementsByTagName("tbody"))
        .expand((element) => element)
        .map((e) => e.getElementsByTagName("tr"))
        .expand((element) => element);

    return (recipeNameElements, servingElements, ingredientElements);
  }

  RecipeMetadata _parseMetaDataNew(Document document) {
    var recipeNameElements = document
        .getElementsByTagName("header")
        .map((e) => e.getElementsByTagName("h1"))
        .expand((element) => element);
    var servingsElement = document.getElementById("quantity");
    var servingElements = <Element>[];
    if (servingsElement != null) servingElements.add(servingsElement);
    servingElements = servingElements.where(_hasIntValueAttribute).toList();
    var ingredientElements = document
        .getElementsByClassName("ds-ingredients-table")
        .map((e) => e.getElementsByTagName("tbody"))
        .expand((element) => element)
        .map((e) => e.getElementsByTagName("tr"))
        .expand((element) => element);

    return (recipeNameElements, servingElements, ingredientElements);
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
    var isNewDesign = element.classes.contains("ds-ingredients-table__tr");

    var ingredientInfo = <String>[];
    if (isNewDesign) {
      var columns = element.getElementsByTagName("td");
      if (columns.length != 2) {
        return IngredientParsingResult(
          logs: [
            SimpleJobLog(subType: JobLogSubType.ingredientParsingFailure, recipeUrl: recipeUrl),
          ],
        );
      }

      var amountUnitString = columns.first.text.trim();
      if (amountUnitString.isNotEmpty) ingredientInfo.add(amountUnitString);

      var spans = columns[1].getElementsByTagName("span");
      ingredientInfo.add(spans.map((s) => s.text.trim()).join(", "));
    } else {
      ingredientInfo = element.getElementsByTagName("span").map((e) => e.text.trim()).toList();
    }

    if (ingredientInfo.isEmpty || ingredientInfo.length > 2) {
      return IngredientParsingResult(
        logs: [SimpleJobLog(subType: JobLogSubType.ingredientParsingFailure, recipeUrl: recipeUrl)],
      );
    }

    var name = ingredientInfo.last;
    var amount = 0.0;
    var unit = "";
    // TODO this can be done better, eat this has similar problems
    if (ingredientInfo.length == 2) {
      var amountUnitString = ingredientInfo.first;
      var amountUnitStrings = amountUnitString.trim().split(RegExp(r"\s+"));
      var splitIndex = 0;
      for (var i = 0; i < amountUnitStrings.length; i++) {
        var amountString = amountUnitStrings.getRange(0, i + 1).join(" ");
        var parsedAmount = tryParseAmountString(amountString, isNewDesign ? "en" : "de");
        // Break if amount cannot be parsed or if rest is unit string
        if (parsedAmount == null || parsedAmount == amount) {
          break;
        }
        splitIndex++;
        amount = parsedAmount;
      }
      unit = amountUnitStrings.getRange(splitIndex, amountUnitStrings.length).join(" ");
    }

    amount *= servingsMultiplier;
    return IngredientParsingResult(
      ingredients: [Ingredient(amount: amount, unit: unit, name: name)],
      logs: <JobLog>[],
    );
  }

  bool _hasIntValueAttribute(Element element) {
    var valueAttribute = element.attributes["value"];
    return int.tryParse(valueAttribute ?? "") != null;
  }
}
