import '../recipe_parser/redirect_parser/redirect_parser.dart';

/// Enum for the supported recipe redirects.
enum RecipeRedirect {
  /// KptnCook.
  kptnCook("sharing.kptncook.com", KptnCookSharingUrlParser());

  /// Returns the [RecipeRedirect] for the passed [url].
  ///
  /// Returns null if the passed [url] is not supported.
  static RecipeRedirect? fromUrl(Uri url) =>
      RecipeRedirect.values.where((redirect) => redirect.urlHost == url.host).firstOrNull;

  const RecipeRedirect(this.urlHost, this.redirectParser);

  /// The host of the website url.
  final String urlHost;

  /// The [RedirectParser] for this website.
  final RedirectParser redirectParser;
}
