import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_log.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'parsing_helper.dart';
import 'recipe_scripts_helper.dart';

List<String> _notSupportedUrls = [
  "https://www.eat-this.org/wie-man-eine-vegane-kaeseplatte-zusammenstellt/",
  "https://www.eat-this.org/veganes-raclette/",
  "https://www.eat-this.org/genial-einfacher-veganer-milchschaum-caffe-latte-mit-coffee-circle/",
  "https://www.eat-this.org/herbstlicher-zwetschgenkuchen/",
  "https://www.eat-this.org/scharfe-mie-nudeln-thai-style/",
];

/// Pattern for the amount information of an ingredient.
const _servingsPattern = "([0-9]+|einen|eine)";
const _uePattern = "(\u00FC|\u0075\u0308)";
final _servingsTextPatterns = [
  RegExp("Zutaten\\sf${_uePattern}r(\\sca.){0,1}\\s$_servingsPattern\\s"),
  RegExp("F${_uePattern}r\\s$_servingsPattern\\s"),
];

/// Parses a [Document] from the Eat This website to a recipe.
RecipeParsingResult parseEatThisRecipe(
  Document document,
  RecipeParsingJob recipeParsingJob,
) {
  if (_notSupportedUrls.contains(recipeParsingJob.url.toString())) {
    return createDeliberatelyNotSupportedUrlParsingResult(
      recipeParsingJob.url.toString(),
    );
  }

  var recipeNameElements = document.getElementsByClassName("entry-title");
  var recipeContainerElementsOldDesign =
      document.getElementsByClassName("zutaten");
  var recipeContainerElementsNewDesign =
      document.getElementsByClassName("wprm-recipe");

  if (recipeNameElements.isEmpty ||
      (recipeContainerElementsOldDesign.isEmpty &&
          recipeContainerElementsNewDesign.isEmpty)) {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }

  var recipeName = recipeNameElements.first.text.trim();

  RecipeParsingResult recipeParsingResult;
  if (recipeContainerElementsNewDesign.isNotEmpty) {
    recipeParsingResult = _parseRecipeNewDesign(
      recipeContainerElementsNewDesign.first,
      recipeName,
      recipeParsingJob,
    );
  } else if (recipeContainerElementsOldDesign.isNotEmpty) {
    recipeParsingResult = _parseRecipeOldDesign(
      recipeContainerElementsOldDesign.first,
      recipeName,
      recipeParsingJob,
    );
  } else {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }

  return recipeParsingResult;
}

RecipeParsingResult _parseRecipeOldDesign(
  Element recipeElement,
  String recipeName,
  RecipeParsingJob recipeParsingJob,
) {
  var possibleServingsElements = recipeElement.getElementsByTagName("p") +
      recipeElement.getElementsByTagName("h3") +
      recipeElement.getElementsByTagName("h2") +
      recipeElement.getElementsByTagName("h4");
  var servingsElements = possibleServingsElements.where(
    (element) => _servingsTextPatterns.any(
      (pattern) => element.text.startsWith(pattern),
    ),
  );

  if (servingsElements.isEmpty) {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }

  var servingsElement = servingsElements.first;

  // Retrieve amount of servings
  var servingsDescriptionText = servingsElement.text;
  var recipeServingsMatch =
      RegExp(_servingsPattern).firstMatch(servingsDescriptionText);
  if (recipeServingsMatch == null || recipeServingsMatch.group(0) == null) {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }

  num recipeServings;
  try {
    recipeServings = num.parse(recipeServingsMatch.group(0)!);
  } on FormatException {
    // When it can't be parsed to a number it's a word for 1 e.g. 'eine'/'einen'
    recipeServings = 1;
  }
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  var ingredientElements = recipeElement.getElementsByTagName("li");

  var ingredientParsingResults = ingredientElements
      .map(
        (element) => parseIngredientOldDesign(
          element,
          servingsMultiplier,
          recipeParsingJob.url.toString(),
          language: recipeParsingJob.language,
        ),
      )
      .toList();

  var logs = ingredientParsingResults
      .map((result) => result.metaDataLogs)
      .expand((metaDataLogs) => metaDataLogs)
      .toList();

  var ingredients = ingredientParsingResults
      .map((result) => result.ingredient)
      .whereType<Ingredient>()
      .toList();

  return RecipeParsingResult(
    recipe: Recipe(
      ingredients: ingredients,
      name: recipeName,
      servings: recipeParsingJob.servings,
    ),
    metaDataLogs: logs,
  );
}

@visibleForTesting

/// Parses an html [Element] representing an [Ingredient] in the old design.
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
IngredientParsingResult parseIngredientOldDesign(
  Element ingredientElement,
  double servingsMultiplier,
  String recipeUrl, {
  String? language,
}) {
  var amount = 0.0;
  var unit = "";
  var name = "";

  var ingredientText = ingredientElement.text;
  var parts = ingredientText.split(" ");
  var parsedParts =
      parts.map((part) => tryParseAmountString(part, language: language));

  // Check for amount first
  var checkIndex = -1;
  for (var parsedPart in parsedParts) {
    if (parsedPart == null) {
      break;
    } else {
      amount += parsedPart;
      checkIndex++;
    }
  }

  // Unit comes second
  if (checkIndex + 1 < parts.length &&
      units.contains(parts[checkIndex + 1].toLowerCase())) {
    unit = parts[checkIndex + 1];
    checkIndex++;
  }

  name = parts.skip(checkIndex + 1).join(" ");

  return IngredientParsingResult(
    ingredient: Ingredient(
      amount: amount * servingsMultiplier,
      unit: unit,
      name: name,
    ),
    metaDataLogs: [],
  );
}

RecipeParsingResult _parseRecipeNewDesign(
  Element recipeElement,
  String recipeName,
  RecipeParsingJob recipeParsingJob,
) {
  var servingsElements =
      recipeElement.getElementsByClassName("wprm-recipe-servings");
  var recipeServings = int.parse(servingsElements.first.text);
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  var ingredientElements =
      recipeElement.getElementsByClassName("wprm-recipe-ingredient");

  var ingredientParsingResults = ingredientElements
      .map(
        (element) => parseIngredientNewDesign(
          element,
          servingsMultiplier,
          recipeParsingJob.url.toString(),
          language: recipeParsingJob.language,
        ),
      )
      .toList();

  var logs = ingredientParsingResults
      .map((result) => result.metaDataLogs)
      .expand((metaDataLogs) => metaDataLogs)
      .toList();

  var ingredients = ingredientParsingResults
      .map((result) => result.ingredient)
      .whereType<Ingredient>()
      .toList();

  return RecipeParsingResult(
    recipe: Recipe(
      ingredients: ingredients,
      name: recipeName,
      servings: recipeParsingJob.servings,
    ),
    metaDataLogs: logs,
  );
}

@visibleForTesting

/// Parses an html [Element] representing an [Ingredient] in the new design.
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
IngredientParsingResult parseIngredientNewDesign(
  Element ingredientElement,
  double servingsMultiplier,
  String recipeUrl, {
  String? language,
}) {
  var amount = 0.0;
  var unit = "";
  var name = "";

  var nameElements =
      ingredientElement.getElementsByClassName("wprm-recipe-ingredient-name");
  if (nameElements.isNotEmpty) {
    var nameElement = nameElements.first;
    // Sometimes the name has a url reference in a <a> tag
    if (nameElement.children.isNotEmpty) {
      name = nameElement.children.map((element) => element.text).join();
    } else {
      name = nameElement.text.trim();
    }
  } else {
    return createFailedIngredientParsingResult(recipeUrl);
  }

  var logs = <MetaDataLog>[];

  var amountElements =
      ingredientElement.getElementsByClassName("wprm-recipe-ingredient-amount");
  if (amountElements.isNotEmpty) {
    var amountElement = amountElements.first;
    var amountString = amountElement.text.trim();
    var parsedAmount = tryParseAmountString(amountString, language: language);
    if (parsedAmount != null) {
      amount = parsedAmount * servingsMultiplier;
    } else {
      logs.add(
        createFailedAmountParsingMetaDataLog(
          recipeUrl,
          amountString,
          name,
        ),
      );
    }
  }

  var unitElements =
      ingredientElement.getElementsByClassName("wprm-recipe-ingredient-unit");
  if (unitElements.isNotEmpty) {
    var unitElement = unitElements.first;
    unit = unitElement.text.trim();
  }

  return IngredientParsingResult(
    ingredient: Ingredient(amount: amount, unit: unit, name: name),
    metaDataLogs: logs,
  );
}

/// Known unit strings.
const units = [
  "mg",
  "g",
  "kg",
  "el",
  "tl",
  "ml",
  "dl",
  "l",
];
