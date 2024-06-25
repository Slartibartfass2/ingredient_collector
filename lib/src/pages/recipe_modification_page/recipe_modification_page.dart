import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../local_storage_controller.dart';
import '../../models/domain/recipe.dart';
import '../../models/local_storage/recipe_modification.dart';
import '../../recipe_controller/recipe_tools.dart';
import '../../widgets/adaptive_container.dart';
import 'recipe_modification_form.dart';

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
          title: const Text(LocaleKeys.recipe_modification_page_title).tr(
            namedArgs: {
              "recipeName": recipe.name,
              "servings": recipe.servings.toString(),
            },
          ),
        ),
        body: _PageBody(recipe: recipe, recipeUrlOrigin: recipeUrlOrigin),
      );
}

class _PageBody extends StatelessWidget {
  final Recipe recipe;

  final String recipeUrlOrigin;

  Widget _builder(
    BuildContext _,
    AsyncSnapshot<List<RecipeModification?>> snapshot,
  ) {
    var data = snapshot.data;
    if (snapshot.hasData && data != null) {
      var modification = data.isEmpty ? null : data.first;
      var modifiedRecipe = modification != null
          ? modifyRecipe(
              recipe: recipe,
              modification: modification,
            )
          : recipe;

      return RecipeModificationForm(
        originalRecipe: recipe,
        recipeUrlOrigin: recipeUrlOrigin,
        modifiedRecipe: modifiedRecipe,
      );
    }

    return Center(
      child: Column(
        children: [
          const Text(LocaleKeys.recipe_modification_loading).tr(),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  const _PageBody({required this.recipe, required this.recipeUrlOrigin});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: AdaptiveContainer(
            child: FutureBuilder(
              future: Future(
                () async => [
                  await LocalStorageController()
                      .getRecipeModification(recipeUrlOrigin, recipe.name),
                ],
              ),
              builder: _builder,
            ),
          ),
        ),
      );
}
