import 'dart:async';
import 'dart:isolate';

import 'element.dart';
import 'parser.dart';

Future<List<TextElement>> exec(Parser parser, String text) async {
  final completer = Completer<List<TextElement>>();
  final receivePort = ReceivePort();

  receivePort.listen((dynamic message) {
    if (message is SendPort) {
      message.send(parser);
      message.send(text);
      return;
    }
    completer.complete(message as List<TextElement>);
    receivePort.close();
  });

  await Isolate.spawn(execInIsolate, receivePort.sendPort);

  return completer.future;
}

void execInIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  late Parser parser;
  receivePort.listen((dynamic message) {
    if (message is Parser) {
      parser = message;
    }
    if (message is String) {
      final list = parser.parse(message);
      sendPort.send(list);
      receivePort.close();
    }
  });
}

Future<List<TextElement>> execFuture(Parser parser, String text) async {
  // Avoids blocking the UI.
  // https://github.com/flutter/flutter/blob/978a2e7bf6a2ed287130af8dbd94cef019fb7bef/packages/flutter/lib/src/foundation/_isolates_web.dart#L9-L12
  await null;
  return parser.parse(text);
}
