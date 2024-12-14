import 'dart:async';
import 'dart:isolate';

import 'element.dart';
import 'parser_body.dart';

class Parser extends ParserBody {
  Parser({
    required super.matchers,
    required super.multiLine,
    required super.caseSensitive,
    required super.unicode,
    required super.dotAll,
  });

  Future<List<TextElement>> parseInIsolate(
    String text, {
    required bool onlyMatches,
  }) async {
    return Isolate.run(() => _parse(this, text, onlyMatches));
  }
}

List<TextElement> _parse(Parser parser, String text, bool onlyMatches) {
  return parser.parse(text, onlyMatches: onlyMatches);
}
