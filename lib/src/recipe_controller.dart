import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import 'meta_data_logs/meta_data_log.dart';
import 'models/recipe.dart';
import 'models/recipe_parsing_job.dart';
import 'models/recipe_parsing_result.dart';
import 'recipe_scripts/recipe_parser.dart';

/// Controller for collecting recipes.
class RecipeController {
  static final RecipeController _singleton = RecipeController._internal();

  final Map<String, RecipeParser> _urlToRecipeParser = {
    'http://mobile.kptncook.com': KptnCookParser(),
    'https://biancazapatka.com': BiancaZapatkaParser(),
    'https://www.eat-this.org': EatThisParser(),
  };

  /// Get Sensor Manager singleton instance.
  factory RecipeController() => _singleton;

  RecipeController._internal();

  /// Collects recipes from the websites in the passed [recipeParsingJobs].
  ///
  /// For each [RecipeParsingJob] a http request is made to the website
  /// containing the recipe. From there the recipe is parsed and adjusted to the
  /// amount of servings. The list of the parsed [Recipe]s is returned.
  /// [language] is set as 'Accept-Language' header in each http request.
  Future<List<RecipeParsingResult>> collectRecipes(
    List<RecipeParsingJob> recipeParsingJobs,
    String language,
  ) async {
    var results = <RecipeParsingResult>[];
    var client = http.Client();

    var headers = <String, String>{
      'Accept-Language': language,
    };

    for (var recipeParsingJob in recipeParsingJobs) {
      var result = await _collectRecipe(client, recipeParsingJob, headers);
      results.add(result);
    }

    client.close();
    return results;
  }

  /// Checks if the passed [Uri] is supported.
  ///
  /// Supported means that there's a parsing script available which can be used
  /// to collect the ingredients of the recipe.
  bool isUrlSupported(Uri url) => _urlToRecipeParser.containsKey(url.origin);

  Future<RecipeParsingResult> _collectRecipe(
    http.Client client,
    RecipeParsingJob recipeParsingJob,
    Map<String, String> headers,
  ) async {
    http.Response response;
    try {
      response = await client.get(recipeParsingJob.url, headers: headers);
    } on http.ClientException {
      return RecipeParsingResult(
        metaDataLogs: [
          MissingCorsPluginMetaDataLog(recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var document = parse(response.body);

    var parser = _urlToRecipeParser[recipeParsingJob.url.origin];

    if (parser == null) {
      // TODO: make this cleaner
      throw Exception(
        'No parser found for url ${recipeParsingJob.url.toString()}',
      );
    }

    return parser.parseRecipe(document, recipeParsingJob);
  }
}
