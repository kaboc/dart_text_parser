import 'matcher.dart';

const _kUrlPattern = r'(?:'
    r'(?:[\w\-]{1,256}\.){1,5}[a-zA-Z]{2,10}'
    r'|\d{1,3}(?:\.\d{1,3}){3}'
    r'|localhost'
    r')'
    // Port number
    r'(?::\d{1,5})?'
    // Delimiter in front of the path
    r'(?:[/?#]'
    r'(?:'
    // Characters that the path can contain
    r"(?:[\w\-.~%!#$&'()*+,/:;=?@\[\]]+/?)*"
    // Characters allowed at the end of the path
    r'[\w\-~/]'
    r')?'
    r')?';

/// A variant of [TextMatcher] for parsing URLs that start with http(s).
class UrlMatcher extends TextMatcher {
  /// Creates a [UrlMatcher] for parsing URLs that start with http(s).
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const UrlMatcher([
    super.pattern = 'https?://$_kUrlPattern',
  ]);
}

/// A variant of [TextMatcher] for parsing URL-like strings.
///
/// The difference from [UrlMatcher] is that [UrlLikeMatcher]
/// also matches URL-like strings not starting with http(s).
class UrlLikeMatcher extends TextMatcher {
  /// Creates a [UrlLikeMatcher] for parsing URLs.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const UrlLikeMatcher([
    super.pattern = '(?:https?:)?(?://)?$_kUrlPattern',
  ]);
}

/// A variant of [TextMatcher] for parsing email addresses.
class EmailMatcher extends TextMatcher {
  /// Creates an [EmailMatcher] for parsing email addresses.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const EmailMatcher([
    super.pattern = r'[\w\-.+]+@(?:[\w\-]{1,256}\.){1,5}[a-zA-Z]{2,10}',
  ]);
}

/// A variant of [TextMatcher] for parsing phone numbers.
class TelMatcher extends TextMatcher {
  /// Creates a [TelMatcher] for parsing phone numbers.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const TelMatcher([
    super.pattern = r'(?<!\d)(?:'
        r'(?:\+?[1-9]\d{0,4}[- ])?\d{1,4}[- ]?\d{3,4}[- ]?\d{3,4}'
        r'|\d{2,5}'
        r')(?!\d)',
  ]);
}
