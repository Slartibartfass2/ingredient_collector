import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import 'recipe-scripts/kptncook.dart';
import 'recipe_models.dart';

final Map<String, Recipe Function(Document, int)> _recipeParseMethodMap = {
  'mobile.kptncook.com': parseKptnCookRecipe,
};

/// Collects recipes from the websites in the passed [recipeInfos].
///
/// For each [RecipeInfo] a http request is made to the website containing the
/// recipe. From there the recipe is parsed and adjusted to the amount of
/// servings. The list of the parsed [Recipe]s is returned.
Future<List<Recipe>> collectRecipes(List<RecipeInfo> recipeInfos) async {
  var results = <Recipe>[];

  var client = http.Client();

  for (var recipe in recipeInfos) {
    var resultRecipe = await _collectRecipe(client, recipe);
    results.add(resultRecipe);
  }

  client.close();

  return results;
}

Future<Recipe> _collectRecipe(http.Client client, RecipeInfo recipe) async {
  var response = await client.get(recipe.url);

  var document = parse(response.body);

  var parseMethod = _recipeParseMethodMap[recipe.url.host];

  return parseMethod!.call(document, recipe.servings);
}
