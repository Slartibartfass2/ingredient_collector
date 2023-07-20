library redirect_parser;

import 'package:html/dom.dart' show Document;

part 'kptncook_sharing_url_parser.dart';

/// Interface for all redirect parsers.
// ignore: one_member_abstracts, we define a common interface for all recipe parsers
abstract class RedirectParser {
  /// Creates a new [RedirectParser].
  const RedirectParser();

  /// Parses a [Document] from a redirect website to a redirect url.
  ///
  /// The [Document] is the parsed html document of the website.
  /// The [Uri] that is returned contains the parsed redirect url or
  /// null if the redirect url couldn't be parsed.
  Uri? getRedirectUrl(
    Document document,
  );
}
