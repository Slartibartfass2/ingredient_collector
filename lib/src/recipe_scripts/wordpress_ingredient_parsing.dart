import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_logs/meta_data_log.dart';
import 'parsing_helper.dart';

/// Parses an html [Element] representing an [Ingredient].
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
IngredientParsingResult parseWordPressIngredient(
  Element element,
  double servingsMultiplier,
  String recipeUrl,
  String? language,
) {
  var name = "";
  var nameElements =
      element.getElementsByClassName("wprm-recipe-ingredient-name");
  if (nameElements.isNotEmpty) {
    var nameElement = nameElements.first;
    // Sometimes the name has a url reference in a <a> tag
    name = nameElement.children.isNotEmpty
        ? nameElement.children.map((element) => element.text).join()
        : nameElement.text.trim();
  } else {
    return IngredientParsingResult(
      metaDataLogs: [
        IngredientParsingFailureMetaDataLog(recipeUrl: recipeUrl),
      ],
    );
  }

  var logs = <MetaDataLog>[];

  var amount = 0.0;
  var amountElements =
      element.getElementsByClassName("wprm-recipe-ingredient-amount");
  if (amountElements.isNotEmpty) {
    var amountElement = amountElements.first;
    var amountString = amountElement.text.trim();
    var parsedAmount = tryParseAmountString(amountString, language: language);
    if (parsedAmount != null) {
      amount = parsedAmount * servingsMultiplier;
    } else {
      logs.add(
        AmountParsingFailureMetaDataLog(
          recipeUrl: recipeUrl,
          amountString: amountString,
          ingredientName: name,
        ),
      );
    }
  }

  var unit = "";
  var unitElements =
      element.getElementsByClassName("wprm-recipe-ingredient-unit");
  if (unitElements.isNotEmpty) {
    var unitElement = unitElements.first;
    unit = unitElement.text.trim();
  }

  return IngredientParsingResult(
    ingredients: [
      Ingredient(amount: amount, unit: unit, name: name),
    ],
    metaDataLogs: logs,
  );
}
