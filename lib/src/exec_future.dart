import 'element.dart';
import 'parser.dart';

Future<List<TextElement>> exec({
  required Parser parser,
  required String text,
  required bool onlyMatches,
}) async {
  return execFuture(parser: parser, text: text, onlyMatches: onlyMatches);
}

Future<List<TextElement>> execFuture({
  required Parser parser,
  required String text,
  required bool onlyMatches,
}) async {
  // Avoids blocking the UI.
  // https://github.com/flutter/flutter/blob/978a2e7bf6a2ed287130af8dbd94cef019fb7bef/packages/flutter/lib/src/foundation/_isolates_web.dart#L9-L12
  await null;
  return parser.parse(text, onlyMatches: onlyMatches);
}
