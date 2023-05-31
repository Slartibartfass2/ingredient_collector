import '../recipe_parser/recipe_parser.dart';

/// Enum for the supported recipe websites.
enum RecipeWebsite {
  /// KptnCook.
  kptnCook("http://mobile.kptncook.com", KptnCookParser()),

  /// Bianca Zapatka.
  biancaZapatka("https://biancazapatka.com", BiancaZapatkaParser()),

  /// Eat This.
  eatThis("https://www.eat-this.org", EatThisParser());

  /// Returns the [RecipeWebsite] for the passed [url].
  ///
  /// Returns null if the passed [url] is not supported.
  static RecipeWebsite? fromUrl(Uri url) {
    var matches = RecipeWebsite.values
        .where((website) => website.urlOrigin == url.origin);
    return matches.isNotEmpty ? matches.first : null;
  }

  const RecipeWebsite(this.urlOrigin, this.recipeParser);

  /// The origin of the website url.
  final String urlOrigin;

  /// The [RecipeParser] for this website.
  final RecipeParser recipeParser;
}
