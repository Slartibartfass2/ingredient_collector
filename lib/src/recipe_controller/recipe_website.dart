import '../recipe_parser/recipe_parser.dart';

/// Enum for the supported recipe websites.
enum RecipeWebsite {
  /// KptnCook.
  kptnCook(["mobile.kptncook.com", "share.kptncook.com"], KptnCookParser()),

  /// Bianca Zapatka.
  biancaZapatka(["biancazapatka.com"], BiancaZapatkaParser()),

  /// Eat This.
  eatThis(["www.eat-this.org"], EatThisParser()),

  /// Chefkoch.
  chefkoch(["www.chefkoch.de"], ChefkochParser()),

  /// Nora Cooks.
  noraCooks(["www.noracooks.com"], NoraCooksParser()),

  /// Simple Veganista.
  simpleVeganista(["simple-veganista.com"], SimpleVeganistaParser());

  /// Returns the [RecipeWebsite] for the passed [url].
  ///
  /// Returns null if the passed [url] is not supported.
  static RecipeWebsite? fromUrl(Uri url) =>
      RecipeWebsite.values.where((website) => website.urlHosts.contains(url.host)).firstOrNull;

  const RecipeWebsite(this.urlHosts, this.recipeParser);

  /// The host of the website url.
  final List<String> urlHosts;

  /// The [RecipeParser] for this website.
  final RecipeParser recipeParser;
}
