import 'matcher.dart';

/// A sub class of [TextMatcher] for parsing URLs.
class UrlMatcher extends TextMatcher {
  /// Creates a UrlMatcher.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const UrlMatcher([String pattern])
      : super(
          pattern ??
              r'(?:https?://)?'
                  r'[\w\-]{2,256}(?:\.[\w\-]{2,256}){1,4}(?::\d{1,5})?/?'
                  r"(?:[\w\-.~%!#$&'()*+,/:;=?@\[\]]+/?)*"
                  r'(?:[^\s.]|$)',
        );
}

/// A sub class of [TextMatcher] for parsing email addresses.
class EmailMatcher extends TextMatcher {
  /// Creates an EmailMatcher.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const EmailMatcher([String pattern])
      : super(
          pattern ?? r'[\w\-.+]+@(?:[\w\-]{2,256}\.)+[a-zA-Z]{2,10}',
        );
}

/// A sub class of [TextMatcher] for parsing phone numbers.
class TelMatcher extends TextMatcher {
  /// Creates a TelMatcher.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const TelMatcher([String pattern])
      : super(
          pattern ??
              r'(?<!\d)(?:'
                  r'\d{2,5}|'
                  r'(?:\+[1-9]\d{0,4}[- ]?)?\d{2,4}[- ]?\d{3,4}[- ]?\d{3,4}'
                  r')(?!\d)',
        );
}
