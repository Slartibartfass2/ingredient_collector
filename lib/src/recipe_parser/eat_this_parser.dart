part of 'recipe_parser.dart';

/// [RecipeParser] implementation for `www.eat-this.org`.
class EatThisParser extends RecipeParser {
  static const _notSupportedUrls = [
    "https://www.eat-this.org/wie-man-eine-vegane-kaeseplatte-zusammenstellt/",
    "https://www.eat-this.org/veganes-raclette/",
    "https://www.eat-this.org/genial-einfacher-veganer-milchschaum-caffe-latte-mit-coffee-circle/",
    "https://www.eat-this.org/herbstlicher-zwetschgenkuchen/",
    "https://www.eat-this.org/scharfe-mie-nudeln-thai-style/",
    "https://www.eat-this.org/artischocken-vinaigrette/",
  ];

  /// Pattern for the amount information of an ingredient.
  static const _servingsPattern = "(?<servings>[0-9]+(-[0-9]+)?|einen|eine|ein)";
  static const _umlautPattern = "(\u00FC|\u0075\u0308)";
  static final _servingsTextPatterns = [
    RegExp("Zutaten\\sf${_umlautPattern}r(\\s(ca\\.|etwa))?\\s$_servingsPattern\\s"),
    RegExp("F${_umlautPattern}r\\s$_servingsPattern\\s"),
  ];

  /// Known unit strings.
  static const _units = [
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

  /// Creates a new [EatThisParser].
  const EatThisParser();

  @override
  RecipeParsingResult parseRecipe(Document document, RecipeParsingJob recipeParsingJob) {
    if (_notSupportedUrls.contains(recipeParsingJob.url.toString())) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(
            subType: JobLogSubType.deliberatelyNotSupportedUrl,
            recipeUrl: recipeParsingJob.url,
          ),
        ],
      );
    }

    var isNewDesign = document.getElementsByClassName("wprm-recipe").isNotEmpty;
    if (isNewDesign) {
      return const WordPressParser().parseRecipe(document, recipeParsingJob);
    }
    return _parseRecipeOldDesign(document, recipeParsingJob);
  }

  /// Parses an html [Element] representing an [Ingredient] in the old design.
  ///
  /// If the parsing fails the ingredient in [IngredientParsingResult] will be
  /// null and a suitable log will be returned.
  @visibleForTesting
  IngredientParsingResult parseIngredientOldDesign(
    Element element,
    double servingsMultiplier,
    Uri recipeUrl,
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
      var splitFirstPart = _breakUpNumberAndText(parts.first);
      parts = splitFirstPart + parts.skip(1).toList();
    }
    var parsedParts = parts.map((part) => tryParseAmountString(part, language: language));

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
    if (checkIndex + 1 < parts.length && _units.contains(parts[checkIndex + 1].toLowerCase())) {
      unit = parts[checkIndex + 1];
      checkIndex++;
    }

    var name = parts.skip(checkIndex + 1).join(" ");
    if (name.isEmpty) {
      return IngredientParsingResult(
        logs: [SimpleJobLog(subType: JobLogSubType.ingredientParsingFailure, recipeUrl: recipeUrl)],
      );
    }

    return IngredientParsingResult(
      ingredients: [Ingredient(amount: amount * servingsMultiplier, unit: unit, name: name)],
    );
  }

  RecipeParsingResult _parseRecipeOldDesign(Document document, RecipeParsingJob recipeParsingJob) {
    var recipeNameElements = document
        .getElementsByClassName("entry-title")
        .map((element) => element.text.trim())
        .where((element) => element.isNotEmpty);
    var recipeContainerElements = document.getElementsByClassName("zutaten");
    var servingsElements = recipeContainerElements
        .map(
          (element) =>
              element.getElementsByTagName("p") +
              element.getElementsByTagName("h3") +
              element.getElementsByTagName("h2") +
              element.getElementsByTagName("h4"),
        )
        .expand((element) => element)
        .where(
          (element) => _servingsTextPatterns.any((pattern) => element.text.startsWith(pattern)),
        );
    var ingredientElements =
        recipeContainerElements
            .map((element) => element.getElementsByTagName("li"))
            .expand((element) => element)
            .toList();

    if (recipeNameElements.isEmpty || servingsElements.isEmpty || ingredientElements.isEmpty) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(subType: JobLogSubType.completeFailure, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var recipeName = recipeNameElements.first;
    var servingsElement = servingsElements.first;

    // Retrieve amount of servings
    var servingsDescriptionText = servingsElement.text;
    var recipeServingsMatch = RegExp(_servingsPattern).firstMatch(servingsDescriptionText);
    var matchGroup = recipeServingsMatch?.namedGroup("servings");
    if (matchGroup == null) {
      return RecipeParsingResult(
        logs: [
          SimpleJobLog(subType: JobLogSubType.completeFailure, recipeUrl: recipeParsingJob.url),
        ],
      );
    }

    var recipeServings = tryParseAmountString(matchGroup);
    recipeServings ??= 1;
    var servingsMultiplier = recipeParsingJob.servings / recipeServings;

    return createResultFromIngredientParsing(
      ingredientElements,
      recipeParsingJob,
      servingsMultiplier,
      recipeName,
      parseIngredientOldDesign,
    );
  }

  IngredientParsingResult? _tryParsePlusConcatenatedIngredients(
    String ingredientText,
    double servingsMultiplier,
    Uri recipeUrl,
    String? language,
  ) {
    var ingredients = ingredientText
        .split("+")
        .map(
          (ingredient) => parseIngredientOldDesign(
            Element.html("<li>${ingredient.trim()}</li>"),
            servingsMultiplier,
            recipeUrl,
            language,
          ),
        );
    if (ingredients.every((ingredient) => ingredient.ingredients.isNotEmpty)) {
      return IngredientParsingResult(
        ingredients:
            ingredients
                .map((result) => result.ingredients)
                .expand((ingredient) => ingredient)
                .toList(),
        logs: ingredients.map((result) => result.logs).expand((log) => log).toList(),
      );
    }
    return null;
  }

  List<String> _breakUpNumberAndText(String numberAndTextString) {
    var result = <String>[""];
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
}
