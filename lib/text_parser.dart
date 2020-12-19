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
  /// [matchers] is a list of [TextMatcher]s to be used for parsing.
  TextParser({List<TextMatcher> matchers}) {
    _parser = Parser(matchers: matchers ?? _kDefaultMatchers);
  }

  Parser _parser;

  /// The list of matchers.
  List<TextMatcher> get matchers => _parser.matchers;
  set matchers(List<TextMatcher> matchers) => _parser.update(matchers);

  /// Parses the provided [text] according to the matchers specified in
  /// the constructor.
  ///
  /// If [useIsolate] is set to `true` or omitted, parsing is executed in
  /// an isolate except on the web which dart:isolate does not support,
  Future<List<TextElement>> parse(String text, {bool useIsolate = true}) async {
    return useIsolate ? exec(_parser, text) : execFuture(_parser, text);
  }
}
