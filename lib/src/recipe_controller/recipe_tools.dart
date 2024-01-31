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
/// It is assumed that the ingredients are unique in both [Recipe.ingredients]
/// and [RecipeModification.modifiedIngredients], meaning that there are not
/// two ingredients with the same name.
/// The [modification] is applied to the [recipe] and the modified recipe is
/// returned.
/// The [modification] is applied to an ingredient with the same name.
/// If the [modification] contains an ingredient that is not in the [recipe],
/// the ingredient is added to the [recipe].
/// The [modification] is applied to the [recipe] by adjusting the amount of
/// each ingredient to the new amount of servings.
/// The modified recipe has the same name and amount of servings as the
/// [recipe].
/// If the [modification] contains an ingredient with a negative amount, the
/// ingredient is removed from the [recipe].
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
///     Ingredient(amount: 10, unit: "g", name: "Test Ingredient"),
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
///     Ingredient(amount: 5, unit: "g", name: "Test Ingredient"),
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

  var recipeIngredients = recipe.ingredients.toList();
  var modifiedIngredients = modification.modifiedIngredients;

  // First remove all ingredients that are in the modification and have a
  // negative amount.
  recipeIngredients.removeWhere(
    (ingredient) => modifiedIngredients.any(
      (modifiedIngredient) =>
          modifiedIngredient.name == ingredient.name &&
          modifiedIngredient.amount < 0,
    ),
  );

  // Fetch all ingredients from the recipe and multiply them with the ratio or
  // replace them with the modified ingredient if available.
  var ingredients = recipeIngredients
      .map(
        (ingredient) => modifiedIngredients.firstWhere(
          (modifiedIngredient) => modifiedIngredient.name == ingredient.name,
          orElse: () => ingredient.copyWith(amount: ingredient.amount / ratio),
        ),
      )
      .map((ingredient) => _multiplyIngredient(ingredient, ratio))
      .toList();

  // Add all ingredients from the modification that are not in the recipe.
  ingredients.addAll(
    modifiedIngredients
        .where(
          (ingredient) =>
              ingredient.amount >= 0 &&
              !ingredients.any(
                (modifiedIngredient) =>
                    modifiedIngredient.name == ingredient.name &&
                    modifiedIngredient.amount >= 0,
              ),
        )
        .map((ingredient) => _multiplyIngredient(ingredient, ratio)),
  );

  return recipe.copyWith(ingredients: ingredients);
}

Ingredient _multiplyIngredient(Ingredient ingredient, double factor) =>
    ingredient.copyWith(amount: ingredient.amount * factor);

/// Merges the passed [Ingredient]s.
///
/// [Ingredient]s with the same name and unit are merged so that the amount is
/// added together.
///
/// Example:
/// ```dart
/// var ingredients = [
///   Ingredient(amount: 4, unit: "g", name: "Sugar"),
///   Ingredient(amount: 8, unit: "g", name: "Sugar"),
/// ];
/// var mergedIngredients = mergeIngredients(ingredients);
/// ```
/// The merged ingredients will be:
/// ```dart
/// [
///   Ingredient(amount: 12, unit: "g", name: "Sugar"),
/// ];
Iterable<Ingredient> mergeIngredients(Iterable<Ingredient> ingredients) {
  var mergedIngredients = <Ingredient>[];

  for (var ingredient in ingredients) {
    var index = mergedIngredients.indexWhere(
      (element) =>
          ingredient.name == element.name && ingredient.unit == element.unit,
    );

    if (index == -1) {
      mergedIngredients.add(ingredient);
    } else {
      var existingIngredient = mergedIngredients[index];
      mergedIngredients[index] = existingIngredient.copyWith(
        amount: existingIngredient.amount + ingredient.amount,
      );
    }
  }

  return mergedIngredients;
}

/// Returns a [RecipeModification] from the passed [servings],
/// [modifiedIngredients] and [removedIngredients].
///
/// The [modifiedIngredients] are the ingredients that are modified in the
/// original recipe and the [removedIngredients] are the ingredients that are
/// removed from the original recipe.
/// The [servings] are the amount of servings of the original recipe.
///
/// Example:
/// ```dart
/// var modifiedIngredients = [
///   Ingredient(amount: 6, unit: "", name: "Apples"),
/// ];
/// var removedIngredients = [
///   Ingredient(amount: -1, unit: "g", name: "Salt"),
/// ];
/// var modification = getModification(
///   servings: 2,
///   modifiedIngredients: modifiedIngredients,
///   removedIngredients: removedIngredients,
/// );
/// ```
/// The returned [RecipeModification] will be:
/// ```dart
/// RecipeModification(
///   servings: 2,
///   modifiedIngredients: [
///     Ingredient(amount: 6, unit: "", name: "Apples"),
///     Ingredient(amount: -1, unit: "g", name: "Salt"),
///   ],
/// );
/// ```
RecipeModification getModification({
  required int servings,
  required Iterable<Ingredient> modifiedIngredients,
  required Iterable<Ingredient> removedIngredients,
}) {
  var ingredients = modifiedIngredients.toList()
    ..addAll(
      removedIngredients.map((ingredient) => ingredient.copyWith(amount: -1)),
    );

  return RecipeModification(
    servings: servings,
    modifiedIngredients: ingredients,
  );
}
