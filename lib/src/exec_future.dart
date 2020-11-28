import 'element.dart';
import 'parser.dart';

Future<List<TextElement>> exec(Parser parser, String text) async {
  return execFuture(parser, text);
}

Future<List<TextElement>> execFuture(Parser parser, String text) async {
  // Avoids blocking the UI.
  // https://github.com/flutter/flutter/blob/978a2e7bf6a2ed287130af8dbd94cef019fb7bef/packages/flutter/lib/src/foundation/_isolates_web.dart#L9-L12
  await null;
  return parser.parse(text);
}
