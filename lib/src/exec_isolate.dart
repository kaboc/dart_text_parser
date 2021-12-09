import 'dart:async';
import 'dart:isolate';

import 'element.dart';
import 'parser.dart';

class _Message {
  const _Message(this.sendPort, this.parser, this.text, this.onlyMatches);

  final SendPort sendPort;
  final Parser parser;
  final String text;
  final bool onlyMatches;
}

Future<List<TextElement>> exec(
  Parser parser,
  String text,
  bool onlyMatches,
) async {
  final receivePort = ReceivePort();
  final sendPort = receivePort.sendPort;

  final message = _Message(sendPort, parser, text, onlyMatches);
  await Isolate.spawn(execInIsolate, message);

  final elements = await receivePort.first as List<TextElement>;
  receivePort.close();

  return elements;
}

void execInIsolate(_Message message) {
  final list = message.parser.parse(message.text, message.onlyMatches);
  message.sendPort.send(list);
}

Future<List<TextElement>> execFuture(
  Parser parser,
  String text,
  bool onlyMatches,
) async {
  // Avoids blocking the UI.
  // https://github.com/flutter/flutter/blob/978a2e7bf6a2ed287130af8dbd94cef019fb7bef/packages/flutter/lib/src/foundation/_isolates_web.dart#L9-L12
  await null;
  return parser.parse(text, onlyMatches);
}
