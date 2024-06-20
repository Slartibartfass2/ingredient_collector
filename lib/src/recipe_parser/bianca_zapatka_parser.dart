part of 'recipe_parser.dart';

/// [RecipeParser] implementation for `biancazapatka.com`.
class BiancaZapatkaParser extends RecipeParser {
  /// Creates a new [BiancaZapatkaParser].
  const BiancaZapatkaParser();

  @override
  RecipeParsingResult parseRecipe(
    Document document,
    RecipeParsingJob recipeParsingJob,
  ) {
    var recipeNameElements =
        document.getElementsByClassName("wprm-recipe-name");
    var servingsElements =
        document.getElementsByClassName("wprm-recipe-servings");
    var ingredientContainers =
        document.getElementsByClassName("wprm-recipe-ingredient");

    if (recipeNameElements.isEmpty ||
        servingsElements.isEmpty ||
        ingredientContainers.isEmpty) {
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
    Uri recipeUrl,
    String? language,
  ) =>
      parseWordPressIngredient(
        element,
        servingsMultiplier,
        recipeUrl,
        language,
      );
}
