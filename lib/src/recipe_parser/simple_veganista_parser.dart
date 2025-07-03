part of 'recipe_parser.dart';

/// [RecipeParser] implementation for `simple-veganista.com`.
class SimpleVeganistaParser extends RecipeParser {
  /// Creates a new [SimpleVeganistaParser].
  const SimpleVeganistaParser();

  /// Known unit strings.
  static const _units = [
    "tablespoon",
    "clove",
    "teaspoon",
    "can",
    "cup",
    "oz",
    "lb",
    "package",
    "bunch",
    "pinch",
    "handful",
    "jar",
    "knob",
    "ear",
    "block",
    "piece",
    "tsp",
    "tsp",
    "tbsp",
    "ounce",
    "head",
    "sprig",
    "inch",
    "few",
    "batch",
    "pint",
    "stalk",
    "pound",
    "bottle",
  ];

  /// Quantifiers found before a unit string.
  static const _quantifiers = ["small", "large", "generous", "dry", "rounded", "heaping"];

  @override
  RecipeParsingResult parseRecipe(Document document, RecipeParsingJob recipeParsingJob) {
    var recipeNameElements = document.getElementsByClassName("tasty-recipes-title");
    var servingsElements = document.getElementsByClassName("tasty-recipes-yield");
    var ingredientElements = document
        .getElementsByClassName("tasty-recipes-ingredients-body")
        .map((container) => container.getElementsByTagName("li"))
        .expand((element) => element);

    if (recipeNameElements.isEmpty || servingsElements.isEmpty || ingredientElements.isEmpty) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(subType: JobLogSubType.completeFailure, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var recipeName = allCapsTextToTitleCase(recipeNameElements.first.text.trim());
    var recipeServingsText = servingsElements.first.text.replaceAll("Serves ", "");
    var recipeServings = tryGetRange(recipeServingsText);
    recipeServings ??= tryParseAmountString(recipeServingsText);

    if (recipeServings == null) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(subType: JobLogSubType.completeFailure, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var servingsMultiplier = recipeParsingJob.servings / recipeServings;

    return createResultFromIngredientParsing(
      ingredientElements,
      recipeParsingJob,
      servingsMultiplier,
      recipeName,
      parseIngredient,
    );
  }

  /// Parses an html [Element] representing an [Ingredient].
  ///
  /// If the parsing fails the ingredient in [IngredientParsingResult] will be
  /// null and a suitable log will be returned.
  @visibleForTesting
  IngredientParsingResult parseIngredient(
    Element element,
    double servingsMultiplier,
    Uri recipeUrl,
    String? language,
  ) {
    var ingredientText = element.text.trim();
    var parts = ingredientText.split(RegExp(r"\s"));

    var parsedParts = parts.map((part) => tryParseAmountString(part, language: language)).toList();

    var amount = 0.0;
    var checkIndex = -1;
    for (var i = 0; i < parsedParts.length; i++) {
      var parsedPart = parsedParts[i];
      if (parsedPart == null) {
        // Is unparsable part a range separator?
        if (isRangeSeparator(parts[i])) {
          var rangeValue = tryGetRange(parts[i - 1] + parts[i] + parts[i + 1]);
          if (rangeValue != null) {
            // subtract previously added value
            amount -= parsedParts[i - 1] ?? 0;
            amount += rangeValue;
            // skip next value
            i++;
            checkIndex += 2;
            continue;
          }
        }
        break;
      } else {
        amount += parsedPart;
        checkIndex++;
      }
    }

    var unit = "";
    var name = "";
    if (checkIndex + 1 < parts.length && _matchesQuantifier(parts[checkIndex + 1].toLowerCase())) {
      unit = "${parts[checkIndex + 1]} ";
      checkIndex++;
    }

    if (checkIndex + 1 < parts.length && _matchesUnit(parts[checkIndex + 1].toLowerCase())) {
      unit += parts[checkIndex + 1];
      checkIndex++;
    } else {
      // if current position was no unit, then add previously optionally added
      // quantifier to ingredient name
      name = unit;
      unit = "";
    }

    name += parts.skip(checkIndex + 1).join(" ");
    if (name.isEmpty) {
      return IngredientParsingResult(
        logs: [SimpleJobLog(subType: JobLogSubType.ingredientParsingFailure, recipeUrl: recipeUrl)],
      );
    }

    var ing = Ingredient(amount: amount, unit: unit, name: name);
    print(ing);

    return IngredientParsingResult(
      ingredients: [Ingredient(amount: amount, unit: unit, name: name)],
      logs: <JobLog>[],
    );
  }

  bool _matchesUnit(String input) => _units.any((e) => RegExp("$e[e|s|.]*").hasMatch(input));

  bool _matchesQuantifier(String input) => _quantifiers.contains(input);
}
