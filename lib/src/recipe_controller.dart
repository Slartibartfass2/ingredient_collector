import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:optional/optional.dart';

import 'models/recipe.dart';
import 'models/recipe_parsing_job.dart';
import 'recipe-scripts/kptncook.dart';

final Map<String, Optional<Recipe> Function(Document, int)>
    _recipeParseMethodMap = {
  'mobile.kptncook.com': parseKptnCookRecipe,
};

/// Collects recipes from the websites in the passed [recipeParsingJobs].
///
/// For each [RecipeParsingJob] a http request is made to the website containing
/// the recipe. From there the recipe is parsed and adjusted to the amount of
/// servings. The list of the parsed [Recipe]s is returned.
/// [language] is set as 'Accept-Language' header in each http request.
Future<List<Recipe>> collectRecipes(
  List<RecipeParsingJob> recipeParsingJobs,
  String language,
) async {
  var results = <Recipe>[];
  var client = http.Client();

  var headers = <String, String>{
    'Accept-Language': language,
  };

  for (var recipeParsingJob in recipeParsingJobs) {
    await _collectRecipe(client, recipeParsingJob, headers).then(
      (optionalRecipe) => optionalRecipe.ifPresent(results.add),
    );
  }

  client.close();
  return results;
}

Future<Optional<Recipe>> _collectRecipe(
  http.Client client,
  RecipeParsingJob recipeParsingJob,
  Map<String, String> headers,
) async {
  var response = await client.get(recipeParsingJob.url, headers: headers);

  var document = parse(response.body);

  var parseMethod = _recipeParseMethodMap[recipeParsingJob.url.host];

  return parseMethod!.call(document, recipeParsingJob.servings);
}

/// Checks if the passed [Uri] is supported.
///
/// Supported means that there's a parsing script available which can be used
/// to collect the ingredients of the recipe.
bool isUrlSupported(Uri url) => _recipeParseMethodMap.containsKey(url.host);
