import 'recipe_parsing_state.dart';

/// Wrapper for [RecipeParsingState] to add the recipe name.
class RecipeParsingStateWrapper {
  /// The state of the recipe parsing process.
  final RecipeParsingState state;

  /// The name of the recipe.
  final String recipeName;

  /// Creates a new [RecipeParsingStateWrapper].
  RecipeParsingStateWrapper({required this.state, this.recipeName = ""});
}
