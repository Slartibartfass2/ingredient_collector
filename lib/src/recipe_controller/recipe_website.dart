import '../recipe_parser/recipe_parser.dart';

/// Enum for the supported recipe websites.
enum RecipeWebsite {
  /// KptnCook.
  kptnCook("mobile.kptncook.com", KptnCookParser()),

  /// Bianca Zapatka.
  biancaZapatka("biancazapatka.com", BiancaZapatkaParser()),

  /// Eat This.
  eatThis("www.eat-this.org", EatThisParser());

  /// Returns the [RecipeWebsite] for the passed [url].
  ///
  /// Returns null if the passed [url] is not supported.
  static RecipeWebsite? fromUrl(Uri url) => RecipeWebsite.values
      .where((website) => website.urlHost == url.host)
      .firstOrNull;

  const RecipeWebsite(this.urlHost, this.recipeParser);

  /// The host of the website url.
  final String urlHost;

  /// The [RecipeParser] for this website.
  final RecipeParser recipeParser;
}
