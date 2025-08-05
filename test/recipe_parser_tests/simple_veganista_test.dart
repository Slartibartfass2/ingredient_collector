import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  test('test name', () async {
    var url = "https://simple-veganista.com/vegan-jambalaya/";

    var recipeJob = RecipeController().createRecipeParsingJob(
      url: Uri.parse(url),
      servings: 2,
      language: "de",
    );

    var result = await RecipeController().collectRecipes(
      recipeParsingJobs: [recipeJob],
      language: "de",
    );

    expect(result.length, 1);
  });
}
