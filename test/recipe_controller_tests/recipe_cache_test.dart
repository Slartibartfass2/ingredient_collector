import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';

void main() {
  setUp(() => RecipeCache().cache.clear());

  test(
    'When the cache is empty and getRecipe is called, then null is returned',
    () {
      var url = Uri.parse("https://example.org/recipe");
      var recipe = RecipeCache().getRecipe(url);
      expect(recipe, isNull);
    },
  );

  test(
    'When the cache contains a recipe and getRecipe is called with the same'
    'properties, then the recipe is returned',
    () {
      var url = Uri.parse("https://example.org/recipe");
      var recipe =
          const Recipe(ingredients: [], name: "test name", servings: 2);

      RecipeCache().cache[RecipeCache().getKey(url)] = recipe;

      var cachedRecipe = RecipeCache().getRecipe(url);
      expect(cachedRecipe, equals(recipe));
    },
  );

  test(
    'When the cache is empty and addRecipe is called, then recipe is added '
    'to the cache.',
    () {
      var url = Uri.parse("https://example.org/recipe");
      var recipe = const Recipe(
        ingredients: [],
        name: "test name",
        servings: 2,
      );

      RecipeCache().addRecipe(url, recipe);

      var cachedRecipe = RecipeCache().cache[RecipeCache().getKey(url)];
      expect(cachedRecipe, isNotNull);
      expect(cachedRecipe, equals(recipe));
    },
  );

  test(
    'When the cache contains a recipe and addRecipe is called with the same '
    'recipe but with different properties, then the cached recipe is '
    'overwritten.',
    () {
      var url = Uri.parse("https://example.org/recipe");
      var recipe = const Recipe(
        ingredients: [],
        name: "test name",
        servings: 2,
      );

      RecipeCache().cache[RecipeCache().getKey(url)] = recipe;

      var newRecipe = const Recipe(
        ingredients: [
          Ingredient(amount: 12.34, unit: "test unit", name: "test name"),
        ],
        name: "test name",
        servings: 2,
      );

      RecipeCache().addRecipe(url, newRecipe);

      var cachedRecipe = RecipeCache().cache[RecipeCache().getKey(url)];
      expect(cachedRecipe, isNotNull);
      expect(cachedRecipe, equals(newRecipe));
    },
  );

  test(
    'When the redirect cache is empty and addRedirect is called, then redirect '
    'is added to the cache.',
    () {
      var url = Uri.parse("https://example.org");
      var redirectUrl = Uri.parse("https://example.org/redirect");

      RecipeCache().addRedirect(url, redirectUrl);

      var cachedRedirectUrl =
          RecipeCache().redirects[RecipeCache().getKey(url)];
      expect(cachedRedirectUrl, isNotNull);
    },
  );

  test(
    'When redirect cache contains redirect and getRedirect is called, then '
    'redirect is returned',
    () {
      var url = Uri.parse("https://example.org");
      var redirectUrl = Uri.parse("https://example.org/redirect");

      RecipeCache().redirects[RecipeCache().getKey(url)] = redirectUrl;

      var cachedRedirectUrl = RecipeCache().getRedirect(url);
      expect(cachedRedirectUrl, isNotNull);
      expect(cachedRedirectUrl, equals(redirectUrl));
    },
  );
}
