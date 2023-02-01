import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:optional/optional.dart';
import 'package:universal_io/io.dart' show Platform;

import 'recipe-scripts/kptncook.dart';
import 'recipe_models.dart' show Recipe, RecipeInfo;

final Map<String, Optional<Recipe> Function(Document, int)>
    _recipeParseMethodMap = {
  'mobile.kptncook.com': parseKptnCookRecipe,
};

/// Collects recipes from the websites in the passed [recipeInfos].
///
/// For each [RecipeInfo] a http request is made to the website containing the
/// recipe. From there the recipe is parsed and adjusted to the amount of
/// servings. The list of the parsed [Recipe]s is returned.
/// [language] is the set as 'Accept-Language' header in each http request, if
/// not passed as argument, the [Platform.localeName] is used.
Future<List<Recipe>> collectRecipes({
  required List<RecipeInfo> recipeInfos,
  String? language,
}) async {
  var results = <Recipe>[];
  var client = http.Client();

  // Get first part of local language e.g. en_US -> en, if not already set
  language ??= Platform.localeName.split("_")[0];
  var headers = <String, String>{
    'Accept-Language': language,
  };

  for (var recipe in recipeInfos) {
    await _collectRecipe(client, recipe, headers).then(
      (optionalRecipe) => optionalRecipe.ifPresent(results.add),
    );
  }

  client.close();
  return results;
}

Future<Optional<Recipe>> _collectRecipe(
  http.Client client,
  RecipeInfo recipe,
  Map<String, String> headers,
) async {
  var response = await client.get(recipe.url, headers: headers);

  var document = parse(response.body);

  var parseMethod = _recipeParseMethodMap[recipe.url.host];

  return parseMethod!.call(document, recipe.servings);
}
