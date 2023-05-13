part of recipe_parser;

/// [RecipeParser] implementation for `biancazapatka.com`.
class BiancaZapatkaParser extends RecipeParser {
  @override
  RecipeParsingResult parseRecipe(
    Document document,
    RecipeParsingJob recipeParsingJob,
  ) {
    var recipeNameElements = document.getElementsByClassName("entry-title");
    var servingsElements =
        document.getElementsByClassName("wprm-recipe-servings");
    var ingredientContainers =
        document.getElementsByClassName("wprm-recipe-ingredient");

    if (recipeNameElements.isEmpty ||
        servingsElements.isEmpty ||
        ingredientContainers.isEmpty) {
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
      ingredientContainers,
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
  ) =>
      parseWordPressIngredient(
        element,
        servingsMultiplier,
        recipeUrl,
        language,
      );
}
