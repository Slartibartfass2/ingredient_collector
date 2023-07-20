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

  /// Cache that stores the redirects with the url origin and url path as key.
  ///
  /// The url origin is the url without the path and query parameters.
  /// The key is build as follows: "<url origin><url path>".
  @visibleForTesting
  final Map<String, Uri> redirects = {};

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
  Recipe? getRecipe(Uri url) {
    var keyUrl = redirects[getKey(url)] ?? url;
    return cache[getKey(keyUrl)];
  }

  /// Adds the passed [recipe] to the cache.
  ///
  /// If the recipe is already cached, it is overwritten.
  void addRecipe(Uri url, Recipe recipe) {
    var keyUrl = redirects[getKey(url)] ?? url;
    cache[getKey(keyUrl)] = recipe;
  }

  /// Adds the passed redirect from [originalUrl] to [redirectUrl] to the cache.
  ///
  /// If the redirect is already cached, it is overwritten.
  void addRedirect(Uri originalUrl, Uri redirectUrl) {
    redirects[getKey(originalUrl)] = redirectUrl;
  }

  /// Returns the redirect for the passed [originalUrl].
  ///
  /// If the redirect is not cached yet, null is returned.
  Uri? getRedirect(Uri originalUrl) => redirects[getKey(originalUrl)];
}
