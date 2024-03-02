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
    return IngredientParsingResult();
  }
}
