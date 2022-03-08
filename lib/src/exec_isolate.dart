import 'dart:async';
import 'dart:isolate';

import 'element.dart';
import 'parser.dart';

class _Message {
  // ignore: avoid_positional_boolean_parameters
  const _Message(this.sendPort, this.parser, this.text, this.onlyMatches);

  final SendPort sendPort;
  final Parser parser;
  final String text;
  final bool onlyMatches;
}

Future<List<TextElement>> exec({
  required Parser parser,
  required String text,
  required bool onlyMatches,
}) async {
  final receivePort = ReceivePort();
  final sendPort = receivePort.sendPort;

  final message = _Message(sendPort, parser, text, onlyMatches);
  await Isolate.spawn(execInIsolate, message);

  return await receivePort.first as List<TextElement>;
}

// ignore: library_private_types_in_public_api
void execInIsolate(_Message message) {
  final list = message.parser.parse(
    message.text,
    onlyMatches: message.onlyMatches,
  );
  Isolate.exit(message.sendPort, list);
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
