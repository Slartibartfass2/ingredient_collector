import 'package:flutter/material.dart' show visibleForTesting;

import '../models/recipe.dart';

/// Cache for recipes.
///
/// The cache is used to store recipes that are already parsed.
/// This is done to avoid parsing the same recipe multiple times.
class RecipeCache {
  /// Cache that stores the recipes with the url origin and url path as key.
  ///
  /// The url origin is the url without the path and query parameters.
  /// The key is build as follows: "<url origin><url path>".
  @visibleForTesting
  final Map<String, Recipe> cache = {};

  static final RecipeCache _singleton = RecipeCache._internal();

  /// Get Recipe Cache singleton instance.
  factory RecipeCache() => _singleton;

  RecipeCache._internal();

  /// Creates the key format from the passed [url].
  @visibleForTesting
  String getKey(Uri url) => "${url.origin}${url.path}";

  /// Returns the [Recipe] for the passed [url].
  ///
  /// If the recipe is not cached yet, null is returned.
  Recipe? getRecipe(Uri url) => cache[getKey(url)];

  /// Adds the passed [recipe] to the cache.
  ///
  /// If the recipe is already cached, it is overwritten.
  void addRecipe(Uri url, Recipe recipe) {
    cache[getKey(url)] = recipe;
  }
}
