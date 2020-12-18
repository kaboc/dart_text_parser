import 'matcher.dart';

/// A variant of [TextMatcher] for parsing URLs.
class UrlMatcher extends TextMatcher {
  /// Creates a [UrlMatcher] for parsing URLs.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const UrlMatcher([
    String pattern = r'(?:https?:)?(?://)?'
        r'[\w\-]{2,256}(?:\.[\w\-]{2,256}){0,4}\.[a-zA-Z]{2,10}'
        r'(?::\d{1,5})?'
        r"(?:[/?#](?:(?:[\w\-.~%!#$&'()*+,/:;=?@\[\]]+/?)*[^\s.])?)?",
  ]) : super(pattern);
}

/// A variant of [TextMatcher] for parsing email addresses.
class EmailMatcher extends TextMatcher {
  /// Creates an [EmailMatcher] for parsing email addresses.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const EmailMatcher([
    String pattern = r'[\w\-.+]+@(?:[\w\-]{2,256}\.)+[a-zA-Z]{2,10}',
  ]) : super(pattern);
}

/// A variant of [TextMatcher] for parsing phone numbers.
class TelMatcher extends TextMatcher {
  /// Creates a [TelMatcher] for parsing phone numbers.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const TelMatcher([
    String pattern = r'(?<!\d)(?:'
        r'(?:\+?[1-9]\d{0,4}[- ])?\d{1,4}[- ]?\d{3,4}[- ]?\d{3,4}'
        r'|\d{2,5}'
        r')(?!\d)',
  ]) : super(pattern);
}
