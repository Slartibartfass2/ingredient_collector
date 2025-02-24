import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../../l10n/locale_keys.g.dart';
import '../job_logs/job_log.dart';
import '../local_storage_controller.dart';
import '../models/recipe.dart';
import '../models/recipe_modification.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'recipe_cache.dart';
import 'recipe_redirect.dart';
import 'recipe_tools.dart';
import 'recipe_website.dart';

/// Controller for collecting recipes.
class RecipeController {
  int _nextRecipeParsingJobId = 0;

  static final RecipeController _singleton = RecipeController._internal();

  /// Get Recipe Controller singleton instance.
  factory RecipeController() => _singleton;

  RecipeController._internal();

  /// Creates a new [RecipeParsingJob] with the passed [url] and [servings].
  RecipeParsingJob createRecipeParsingJob({
    required Uri url,
    required int servings,
    required String language,
  }) {
    var id = _nextRecipeParsingJobId++;
    return RecipeParsingJob(id: id, url: url, servings: servings, language: language);
  }

  /// Collects recipes from the websites in the passed [recipeParsingJobs].
  ///
  /// For each [RecipeParsingJob] a http request is made to the website
  /// containing the recipe. From there the recipe is parsed and adjusted to the
  /// amount of servings. The iterable of the parsed [Recipe]s is returned.
  /// [language] is set as 'Accept-Language' header in each http request.
  ///
  /// If the recipe is successfully parsed, [onSuccessfullyParsedRecipe] is
  /// called with the [RecipeParsingJob] as argument.
  /// If the recipe couldn't be
  /// parsed, [onFailedParsedRecipe] is called with the [RecipeParsingJob] as
  /// argument.
  /// [onRecipeParsingStarted] is called with the [RecipeParsingJob] as argument
  /// when the parsing of the recipe starts.
  Future<Iterable<RecipeParsingResult>> collectRecipes({
    required Iterable<RecipeParsingJob> recipeParsingJobs,
    required String language,
    void Function(RecipeParsingJob, String)? onSuccessfullyParsedRecipe,
    void Function(RecipeParsingJob)? onFailedParsedRecipe,
    void Function(RecipeParsingJob)? onRecipeParsingStarted,
  }) async {
    var results = <RecipeParsingResult>[];
    var client = http.Client();

    var headers = <String, String>{'Accept-Language': language};

    recipeParsingJobs = await Future.wait(
      recipeParsingJobs.map((job) => _getRedirectRecipeParsingJob(client, job)),
    );

    for (var recipeParsingJob in recipeParsingJobs) {
      if (onRecipeParsingStarted != null) {
        onRecipeParsingStarted(recipeParsingJob);
      }

      var cachedRecipe = RecipeCache().getRecipe(recipeParsingJob.url);

      RecipeParsingResult result;
      if (cachedRecipe == null) {
        result = await _collectRecipe(client, recipeParsingJob, headers);
        var recipe = result.recipe;
        if (recipe != null) {
          RecipeCache().addRecipe(recipeParsingJob.url, recipe);
        }
      } else {
        result = RecipeParsingResult(
          recipe: Recipe.withServings(cachedRecipe, recipeParsingJob.servings),
          logs: [],
        );
      }

      var recipeUrlOrigin = recipeParsingJob.url.origin;
      result = await applyRecipeModification(result, recipeUrlOrigin);

      // Call callbacks
      if (result.recipe == null && onFailedParsedRecipe != null) {
        onFailedParsedRecipe(recipeParsingJob);
      } else if (result.recipe != null && onSuccessfullyParsedRecipe != null) {
        var recipe = result.recipe;
        var message = recipe != null ? recipe.name : "";
        if (result.wasModified) {
          message += " (${LocaleKeys.recipe_row_modified.tr()})";
        }
        onSuccessfullyParsedRecipe(recipeParsingJob, message);
      }

      results.add(result);
    }

    client.close();
    return results;
  }

  /// Checks if the passed [Uri] is supported.
  ///
  /// Supported means that there's a parsing script available which can be used
  /// to collect the ingredients of the recipe.
  bool isUrlSupported(Uri url) =>
      RecipeWebsite.fromUrl(url) != null || RecipeRedirect.fromUrl(url) != null;

  /// Applies the [RecipeModification] to the passed [RecipeParsingResult].
  ///
  /// If the [RecipeModification] is null, the [RecipeParsingResult] is returned
  /// unchanged.
  ///
  /// If the [RecipeModification] is not null, the [RecipeModification] is
  /// applied to the [RecipeParsingResult.recipe] and the [RecipeParsingResult]
  /// is returned with the modified [RecipeParsingResult.recipe].
  ///
  /// A [AdditionalRecipeInformationJobLog] is added to the
  /// [RecipeParsingResult.logs] containing the [RecipeModification]
  /// and the note.
  @visibleForTesting
  Future<RecipeParsingResult> applyRecipeModification(
    RecipeParsingResult result,
    String recipeUrlOrigin,
  ) async {
    var recipe = result.recipe;
    var additionalInformation = await LocalStorageController().getAdditionalRecipeInformation(
      recipeUrlOrigin,
      recipe != null ? recipe.name : "",
    );

    if (recipe == null || additionalInformation == null) {
      return result;
    }

    var modification = additionalInformation.recipeModification;
    var isModificationEmpty = modification == null || (modification.modifiedIngredients.isEmpty);
    if (!isModificationEmpty) {
      recipe = modifyRecipe(recipe: recipe, modification: modification);
    }

    var logs = <JobLog>[
      ...result.logs,
      ...additionalInformation.note.isNotEmpty
          ? [
            AdditionalRecipeInformationJobLog(
              recipeName: recipe.name,
              note: additionalInformation.note,
            ),
          ]
          : [],
    ];

    return result.copyWith(recipe: recipe, logs: logs, wasModified: !isModificationEmpty);
  }

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
        logs: [
          SimpleJobLog(subType: JobLogSubType.missingCorsPlugin, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    if (!_isSuccessStatusCode(response.statusCode)) {
      return RecipeParsingResult(
        logs: [
          RequestFailureJobLog(
            recipeUrl: recipeParsingJob.url,
            statusCode: response.statusCode,
            responseMessage: response.body,
          ),
        ],
      );
    }

    var document = parse(response.body);

    var recipeWebsite = RecipeWebsite.fromUrl(recipeParsingJob.url);

    if (recipeWebsite == null) {
      return const RecipeParsingResult(logs: []);
    }

    var result = recipeWebsite.recipeParser.parseRecipe(document, recipeParsingJob);
    var recipe = result.recipe;
    Recipe? mergedRecipe;
    if (recipe != null) {
      mergedRecipe = recipe.copyWith(
        name: _escapeName(recipe.name),
        ingredients:
            mergeIngredients(
              recipe.ingredients,
            ).map((elem) => elem.copyWith(name: _escapeName(elem.name))).toList(),
      );
    }
    return result.copyWith(recipe: mergedRecipe);
  }

  Future<RecipeParsingJob> _getRedirectRecipeParsingJob(
    http.Client client,
    RecipeParsingJob recipeParsingJob,
  ) async {
    var redirectParser =
        RecipeRedirect.values
            .where((element) => element.urlHost == recipeParsingJob.url.host)
            .firstOrNull
            ?.redirectParser;

    if (redirectParser == null) {
      return recipeParsingJob;
    }

    http.Response response;
    try {
      response = await client.get(recipeParsingJob.url);
    } on http.ClientException {
      // Return original job, so error can be handled in collectRecipes
      return recipeParsingJob;
    }
    var document = parse(response.body);

    var url = redirectParser.getRedirectUrl(document);

    if (url != null) {
      RecipeCache().addRedirect(recipeParsingJob.url, url);
    }

    return recipeParsingJob.copyWith(url: url ?? recipeParsingJob.url);
  }

  bool _isSuccessStatusCode(int statusCode) => (statusCode ~/ 100) == 2;
}

String _escapeName(String name) => name.replaceAll("\"", "'");
