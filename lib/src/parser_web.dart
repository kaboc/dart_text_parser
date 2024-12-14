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
    return parseAsync(text, onlyMatches: onlyMatches);
  }
}
