import 'package:html/dom.dart';

import '../job_logs/job_log.dart';
import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import 'parsing_helper.dart';

/// Parses an html [Element] representing an [Ingredient].
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
IngredientParsingResult parseWordPressIngredient(
  Element element,
  double servingsMultiplier,
  Uri recipeUrl,
  String? language,
) {
  var name = "";
  var nameElements =
      element.getElementsByClassName("wprm-recipe-ingredient-name");
  if (nameElements.isEmpty) {
    return IngredientParsingResult(
      logs: [
        SimpleJobLog(
          subType: JobLogSubType.ingredientParsingFailure,
          recipeUrl: recipeUrl,
        ),
      ],
    );
  }

  var nameElement = nameElements.first;
  // Sometimes the name has a url reference in a <a> tag
  name = nameElement.children.isNotEmpty
      ? nameElement.children.map((element) => element.text).join()
      : nameElement.text.trim();

  var logs = <JobLog>[];

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
        AmountParsingFailureJobLog(
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
    logs: logs,
  );
}
