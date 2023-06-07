import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_modification.dart';
import '../models/recipe_parsing_job.dart';

/// Merges the passed [RecipeParsingJob]s.
///
/// If two [RecipeParsingJob]s have the same url, they are merged into one
/// [RecipeParsingJob] with the sum of the servings.
/// The merged [RecipeParsingJob]s are returned.
/// The order of the [RecipeParsingJob]s is preserved.
/// If [jobs] is empty, an empty [Iterable] is returned.
///
/// Example:
/// ```dart
/// var jobs = [
///   RecipeParsingJob(
///     url: 'https://www.example.com/recipe1',
///     servings: 2,
///   ),
///   RecipeParsingJob(
///     url: 'https://www.example.com/recipe2',
///     servings: 4,
///   ),
///   RecipeParsingJob(
///     url: 'https://www.example.com/recipe1',
///     servings: 3,
///   ),
/// ];
///
/// var mergedJobs = mergeRecipeParsingJobs(jobs);
/// ```
/// The merged jobs are:
/// ```dart
/// [
///   RecipeParsingJob(
///     url: 'https://www.example.com/recipe1',
///     servings: 5,
///   ),
///   RecipeParsingJob(
///     url: 'https://www.example.com/recipe2',
///     servings: 4,
///   ),
/// ]
/// ```
Iterable<RecipeParsingJob> mergeRecipeParsingJobs(
  Iterable<RecipeParsingJob> jobs,
) {
  var mergedJobs = <RecipeParsingJob>[];
  for (var job in jobs) {
    var existingJobIndex = mergedJobs.indexWhere(
      (mergedJob) => mergedJob.url == job.url,
    );
    if (existingJobIndex == -1) {
      mergedJobs.add(job);
    } else {
      var existingJob = mergedJobs[existingJobIndex];
      mergedJobs[existingJobIndex] = existingJob.copyWith(
        servings: existingJob.servings + job.servings,
      );
    }
  }
  return mergedJobs;
}

/// Modifies the passed [recipe] with the passed [modification].
///
/// The [modification] is applied to the [recipe] and the modified recipe is
/// returned.
/// The [modification] is applied to an ingredient with the same name.
/// If the [modification] contains an ingredient that is not in the [recipe],
/// the ingredient is added to the [recipe].
/// The [modification] is applied to the [recipe] by adjusting the amount of
/// each ingredient to the new amount of servings.
/// The modified recipe has the same name and amount of servings as the
/// [recipe].
///
/// Example:
/// ```dart
/// var recipe = const Recipe(
///   ingredients: [
///     Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
///   ],
///   name: "Test Recipe",
///   servings: 2,
/// );
///
/// var modification = const RecipeModification(
///   servings: 4,
///   modifiedIngredients: [
///     Ingredient(amount: 10, unit: "kg", name: "Test Ingredient"),
///   ],
/// );
///
/// var modifiedRecipe = modifyRecipe(
///   recipe: recipe,
///   modification: modification,
/// );
/// ```
/// The modified recipe will be:
/// ```dart
/// Recipe(
///   ingredients: [
///     Ingredient(amount: 5, unit: "kg", name: "Test Ingredient"),
///   ],
///   name: "Test Recipe",
///   servings: 2,
/// );
/// ```
Recipe modifyRecipe({
  required Recipe recipe,
  required RecipeModification modification,
}) {
  var ratio = recipe.servings / modification.servings;

  var modifiedIngredients = modification.modifiedIngredients;
  var newIngredients = recipe.ingredients
      .map(
        (ingredient) => modifiedIngredients.firstWhere(
          (modifiedIngredient) => modifiedIngredient.name == ingredient.name,
          orElse: () => ingredient.copyWith(amount: ingredient.amount / ratio),
        ),
      )
      .map((ingredient) => _multiplyIngredient(ingredient, ratio))
      .toList()
    ..addAll(
      modifiedIngredients
          .where(
            (modifiedIngredient) => !recipe.ingredients.any(
              (ingredient) => ingredient.name == modifiedIngredient.name,
            ),
          )
          .map((ingredient) => _multiplyIngredient(ingredient, ratio)),
    );

  return recipe.copyWith(
    ingredients: newIngredients,
  );
}

Ingredient _multiplyIngredient(Ingredient ingredient, double factor) =>
    ingredient.copyWith(amount: ingredient.amount * factor);
