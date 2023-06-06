import 'package:flutter/material.dart';

import '../models/recipe.dart';

/// The page for modifying a recipe.
class RecipeModificationPage extends StatelessWidget {
  /// The recipe to modify.
  final Recipe recipe;

  /// The url origin of the recipe to modify.
  final String recipeUrlOrigin;

  /// Creates a recipe modification page.
  const RecipeModificationPage({
    super.key,
    required this.recipe,
    required this.recipeUrlOrigin,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Modifiy '${recipe.name}'}'"),
        ),
        body: const Center(
          child: Text("Recipe Modification Page"),
        ),
      );
}
