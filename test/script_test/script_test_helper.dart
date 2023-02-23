import 'package:flutter_test/flutter_test.dart' show fail;
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/meta_data_log.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_result.dart';

void expectIngredient(
  Recipe recipe,
  String name, {
  double amount = 0.0,
  String unit = "",
}) {
  var ingredient = Ingredient(amount: amount, unit: unit, name: name);
  var isInRecipe = recipe.ingredients.contains(ingredient);
  if (!isInRecipe) {
    fail("$ingredient was not found in the recipe");
  }
}

bool hasParsingErrors(RecipeParsingResult result) => result.metaDataLogs
    .where((element) => element.type == MetaDataLogType.error)
    .isNotEmpty;
