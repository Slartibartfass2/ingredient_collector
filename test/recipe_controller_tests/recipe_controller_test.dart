import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';

void main() {
  test(
    'When recipe is parsed again, then the cached recipe is used to create the '
    'RecipeParsingResult',
    () async {
      RecipeCache().cache.clear();

      var job = RecipeParsingJob(
        url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/50d87d41"),
        servings: 4,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [job],
        language: "de",
      ).then((value) => value.first);

      expect(result.recipe, isNotNull);
      var recipe = result.recipe!;
      expect(RecipeCache().getRecipe(job.url), equals(recipe));

      var secondResult = await RecipeController().collectRecipes(
        recipeParsingJobs: [job.copyWith(servings: 2)],
        language: "de",
      ).then((value) => value.first);

      expect(secondResult.recipe, isNotNull);
      var secondRecipe = secondResult.recipe!;
      expect(secondRecipe, isNot(equals(recipe)));
      expect(secondRecipe.servings, equals(2));
      expect(RecipeCache().getRecipe(job.url), equals(recipe));
    },
  );
}
