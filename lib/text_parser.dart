import 'src/element.dart';
import 'src/exec_future.dart' if (dart.library.io) 'src/exec_isolate.dart';
import 'src/matcher.dart';
import 'src/parser.dart';
import 'src/preset_matchers.dart';

export 'src/element.dart';
export 'src/matcher.dart';
export 'src/preset_matchers.dart';

const _kDefaultMatchers = [UrlMatcher(), EmailMatcher(), TelMatcher()];

/// A class that parses text according to specified matchers.
class TextParser {
  /// Creates a [TextParser] that parses text according to specified matchers.
  ///
  /// [matchers] is a list of [TextMatcher]s to be used for parsing. If it
  /// is omitted, the three preset matchers (`UrlMatcher`, `EmailMatcher`
  /// and `TelMatcher`) are used.
  ///
  /// If [multiLine] is enabled, then `^` and `$` will match the beginning
  /// and end of a _line_, in addition to matching beginning and end of
  /// input, respectively.
  ///
  /// If [caseSensitive] is disabled, then case is ignored.
  ///
  /// If [unicode] is enabled, then the pattern is treated as a Unicode
  /// pattern as described by the ECMAScript standard.
  ///
  /// If [dotAll] is enabled, then the `.` pattern will match _all_
  /// characters, including line terminators.
  TextParser({
    List<TextMatcher> matchers = _kDefaultMatchers,
    bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false,
  }) {
    _parser = Parser(
      matchers: matchers,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      unicode: unicode,
      dotAll: dotAll,
    );
  }

  late final Parser _parser;

  /// The list of matchers.
  List<TextMatcher> get matchers => _parser.matchers;

  set matchers(List<TextMatcher> matchers) => _parser.update(matchers);

  /// Parses the provided [text] according to the matchers specified in
  /// the constructor.
  ///
  /// The result contains all the elements in text including the ones
  /// not matching any pattern provided by matchers unless [onlyMatches]
  /// is set to `true` explicitly.
  ///
  /// Parsing is executed in an isolate by default except on the web,
  /// which dart:isolate does not support. It is for preventing the
  /// impact of heavy computation on other processes, but it instead
  /// adds some overhead and result in longer execution time. If you
  /// prefer to use the main thread, set [useIsolate] to 'false'.
  Future<List<TextElement>> parse(
    String text, {
    bool onlyMatches = false,
    bool useIsolate = true,
  }) async {
    return useIsolate
        ? exec(_parser, text, onlyMatches)
        : execFuture(_parser, text, onlyMatches);
  }
}
