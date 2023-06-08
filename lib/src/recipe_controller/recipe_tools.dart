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
/// and [RecipeModification.modifiedIngredients], meaing that there are not
/// two ingredients with the same name and unit.
/// The [modification] is applied to the [recipe] and the modified recipe is
/// returned.
/// The [modification] is applied to an ingredient with the same name and unit.
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

  var modifiedIngredients = modification.modifiedIngredients;

  // First remove ingredients that are deleted in the modification (amount < 0).
  var newIngredients = recipe.ingredients.where(
    (ingredient) => modifiedIngredients.any(
      (modifiedIngredient) =>
          modifiedIngredient.name == ingredient.name &&
          modifiedIngredient.unit == ingredient.unit &&
          modifiedIngredient.amount >= 0,
    ),
  );
  modifiedIngredients = modifiedIngredients
      .where((modifiedIngredient) => modifiedIngredient.amount >= 0)
      .toList();

  // Then modify the remaining ingredients.
  newIngredients = newIngredients
      .map(
        (ingredient) => modifiedIngredients.firstWhere(
          (modifiedIngredient) =>
              modifiedIngredient.name == ingredient.name &&
              modifiedIngredient.unit == ingredient.unit,
          orElse: () => ingredient.copyWith(amount: ingredient.amount / ratio),
        ),
      )
      .map((ingredient) => _multiplyIngredient(ingredient, ratio))
      .toList()

    // Finally add all ingredients that are new in the modification.
    ..addAll(
      modifiedIngredients
          .where(
            (modifiedIngredient) => !recipe.ingredients.any(
              (ingredient) =>
                  ingredient.name == modifiedIngredient.name &&
                  ingredient.unit == modifiedIngredient.unit,
            ),
          )
          .map((ingredient) => _multiplyIngredient(ingredient, ratio)),
    );

  return recipe.copyWith(
    ingredients: newIngredients.toList(),
  );
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
