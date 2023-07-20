part of redirect_parser;

/// [RedirectParser] implementation for `sharing.kptncook.com`.
class KptnCookSharingUrlParser extends RedirectParser {
  /// Creates a new [KptnCookSharingUrlParser].
  const KptnCookSharingUrlParser();

  @override
  Uri? getRedirectUrl(Document document) {
    var urlElements = document.getElementsByClassName("secondary-action");
    var href = urlElements.firstOrNull?.attributes["href"];
    if (urlElements.isEmpty || href == null) {
      return null;
    }

    if (!href.startsWith("http://")) {
      href = "http://$href";
    }
    return Uri.parse(href);
  }
}
