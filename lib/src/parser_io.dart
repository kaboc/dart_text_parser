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
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;

    final message = _Message(sendPort, this, text, onlyMatches);
    await Isolate.spawn(_parse, message);

    return await receivePort.first as List<TextElement>;
  }
}

class _Message {
  // ignore: avoid_positional_boolean_parameters
  const _Message(this.sendPort, this.parser, this.text, this.onlyMatches);

  final SendPort sendPort;
  final Parser parser;
  final String text;
  final bool onlyMatches;
}

void _parse(_Message message) {
  final list = message.parser.parse(
    message.text,
    onlyMatches: message.onlyMatches,
  );
  Isolate.exit(message.sendPort, list);
}
