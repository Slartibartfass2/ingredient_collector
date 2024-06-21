library recipe_parser;

import 'package:flutter/material.dart' show visibleForTesting;
import 'package:html/dom.dart' show Document, Element;

import '../job_logs/job_log.dart';
import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'parsing_helper.dart';
import 'wordpress_ingredient_parsing.dart';

part 'bianca_zapatka_parser.dart';
part 'chefkoch_parser.dart';
part 'eat_this_parser.dart';
part 'kptncook_parser.dart';

/// Interface for all recipe parsers.
// ignore: one_member_abstracts, we define a common interface for all recipe parsers
abstract class RecipeParser {
  /// Creates a new [RecipeParser].
  const RecipeParser();

  /// Parses a [Document] from a website to a recipe using the passed
  /// [RecipeParsingJob].
  ///
  /// The [RecipeParsingJob] contains the url of the website and the amount of
  /// servings the recipe should be adjusted to.
  /// The [Document] is the parsed html document of the website.
  ///
  /// The [RecipeParsingResult] that is returned contains the parsed recipe or
  /// an error message if the recipe couldn't be parsed.
  RecipeParsingResult parseRecipe(
    Document document,
    RecipeParsingJob recipeParsingJob,
  );
}
