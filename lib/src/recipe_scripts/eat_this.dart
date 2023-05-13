import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_logs/meta_data_log.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'parsing_helper.dart';
import 'wordpress_ingredient_parsing.dart';

List<String> _notSupportedUrls = [
  "https://www.eat-this.org/wie-man-eine-vegane-kaeseplatte-zusammenstellt/",
  "https://www.eat-this.org/veganes-raclette/",
  "https://www.eat-this.org/genial-einfacher-veganer-milchschaum-caffe-latte-mit-coffee-circle/",
  "https://www.eat-this.org/herbstlicher-zwetschgenkuchen/",
  "https://www.eat-this.org/scharfe-mie-nudeln-thai-style/",
  "https://www.eat-this.org/artischocken-vinaigrette/",
];

/// Pattern for the amount information of an ingredient.
const _servingsPattern = "(?<servings>[0-9]+(-[0-9]+)?|einen|eine|ein)";
const _uePattern = "(\u00FC|\u0075\u0308)";
final _servingsTextPatterns = [
  RegExp("Zutaten\\sf${_uePattern}r(\\s(ca\\.|etwa))?\\s$_servingsPattern\\s"),
  RegExp("F${_uePattern}r\\s$_servingsPattern\\s"),
];

/// Known unit strings.
const units = [
  "mg",
  "g",
  "kg",
  "el",
  "tl",
  "ml",
  "cl",
  "dl",
  "l",
  "liter",
  "pkg.",
  "pkg",
  "prise",
  "stangen",
  "bund",
  "portionen",
  "cm",
  "dm",
  "m",
  "handvoll",
  "päckchen",
  "stück",
  "zweige",
];

/// Parses a [Document] from the Eat This website to a recipe.
RecipeParsingResult parseEatThisRecipe(
  Document document,
  RecipeParsingJob recipeParsingJob,
) {
  if (_notSupportedUrls.contains(recipeParsingJob.url.toString())) {
    return RecipeParsingResult(
      metaDataLogs: [
        DeliberatelyNotSupportedUrlMetaDataLog(recipeUrl: recipeParsingJob.url),
      ],
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
    return RecipeParsingResult(
      metaDataLogs: [
        CompleteFailureMetaDataLog(recipeUrl: recipeParsingJob.url),
      ],
    );
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
    return RecipeParsingResult(
      metaDataLogs: [
        CompleteFailureMetaDataLog(recipeUrl: recipeParsingJob.url),
      ],
    );
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
    return RecipeParsingResult(
      metaDataLogs: [
        CompleteFailureMetaDataLog(recipeUrl: recipeParsingJob.url),
      ],
    );
  }

  var servingsElement = servingsElements.first;

  // Retrieve amount of servings
  var servingsDescriptionText = servingsElement.text;
  var recipeServingsMatch =
      RegExp(_servingsPattern).firstMatch(servingsDescriptionText);
  var matchGroup = recipeServingsMatch?.namedGroup("servings");
  if (matchGroup == null) {
    return RecipeParsingResult(
      metaDataLogs: [
        CompleteFailureMetaDataLog(recipeUrl: recipeParsingJob.url),
      ],
    );
  }

  var recipeServings = tryParseAmountString(matchGroup);
  recipeServings ??= 1;
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  var ingredientElements = recipeElement.getElementsByTagName("li");

  return createResultFromIngredientParsing(
    ingredientElements,
    recipeParsingJob,
    servingsMultiplier,
    recipeName,
    parseIngredientOldDesign,
  );
}

/// Parses an html [Element] representing an [Ingredient] in the old design.
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
@visibleForTesting
IngredientParsingResult parseIngredientOldDesign(
  Element element,
  double servingsMultiplier,
  String recipeUrl,
  String? language,
) {
  var ingredientText = element.text.trim();

  // Are there two ingredients
  if (ingredientText.contains("+")) {
    var result = _tryParsePlusConcatenatedIngredients(
      ingredientText,
      servingsMultiplier,
      recipeUrl,
      language,
    );
    if (result != null) {
      return result;
    }
  }

  var parts = ingredientText.split(RegExp(r"\s"));
  // If first part is not already a number, check whether the amount and unit
  // are concatenated
  if (tryParseAmountString(parts.first) == null) {
    var splittedFirstPart = _breakUpNumberAndText(parts.first);
    parts = splittedFirstPart + parts.skip(1).toList();
  }
  var parsedParts =
      parts.map((part) => tryParseAmountString(part, language: language));

  var amount = 0.0;
  var checkIndex = -1;
  for (var parsedPart in parsedParts) {
    if (parsedPart == null) {
      break;
    } else {
      amount += parsedPart;
      checkIndex++;
    }
  }

  var unit = "";
  if (checkIndex + 1 < parts.length &&
      units.contains(parts[checkIndex + 1].toLowerCase())) {
    unit = parts[checkIndex + 1];
    checkIndex++;
  }

  var name = parts.skip(checkIndex + 1).join(" ");
  if (name.isEmpty) {
    return IngredientParsingResult(
      metaDataLogs: [
        IngredientParsingFailureMetaDataLog(recipeUrl: recipeUrl),
      ],
    );
  }

  return IngredientParsingResult(
    ingredients: [
      Ingredient(
        amount: amount * servingsMultiplier,
        unit: unit,
        name: name,
      ),
    ],
  );
}

IngredientParsingResult? _tryParsePlusConcatenatedIngredients(
  String ingredientText,
  double servingsMultiplier,
  String recipeUrl,
  String? language,
) {
  var ingredients = ingredientText.split("+").map(
        (ingredient) => parseIngredientOldDesign(
          Element.html("<li>${ingredient.trim()}</li>"),
          servingsMultiplier,
          recipeUrl,
          language,
        ),
      );
  if (ingredients.every((ingredient) => ingredient.ingredients.isNotEmpty)) {
    return IngredientParsingResult(
      ingredients: ingredients
          .map((result) => result.ingredients)
          .expand((ingredient) => ingredient)
          .toList(),
      metaDataLogs: ingredients
          .map((result) => result.metaDataLogs)
          .expand((log) => log)
          .toList(),
    );
  }
  return null;
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

  return createResultFromIngredientParsing(
    ingredientElements,
    recipeParsingJob,
    servingsMultiplier,
    recipeName,
    parseIngredientNewDesign,
  );
}

/// Parses an html [Element] representing an [Ingredient] in the new design.
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
@visibleForTesting
IngredientParsingResult parseIngredientNewDesign(
  Element element,
  double servingsMultiplier,
  String recipeUrl,
  String? language,
) =>
    parseWordPressIngredient(
      element,
      servingsMultiplier,
      recipeUrl,
      language,
    );

List<String> _breakUpNumberAndText(String numberAndTextString) {
  var result = <String>[
    "",
  ];
  var unitIndex = 0;
  for (var i = 0; i < numberAndTextString.length; i++) {
    var number = num.tryParse(numberAndTextString[i]);
    if (number != null) {
      result.first += number.toString();
    } else {
      unitIndex = i;
      break;
    }
  }

  if (unitIndex > 0) {
    result.add(numberAndTextString.substring(unitIndex));
  } else {
    result.first = numberAndTextString;
  }

  return result;
}
