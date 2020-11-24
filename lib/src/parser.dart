import 'dart:async';
import 'dart:isolate';
import 'package:meta/meta.dart';

import 'matcher.dart';
import 'preset_matchers.dart';

part 'element.dart';

const _kIsWeb = identical(0, 0.0);
const _kDefaultMatchers = [UrlMatcher(), EmailMatcher(), TelMatcher()];
const _kNamedGroupPrefix = 'ng';

/// A class that parses text according to specified matchers.
class TextParser {
  /// Creates a [TextParser] that parses text according to specified matchers.
  ///
  /// [matchers] is a list of [TextMatcher]s to be used for parsing.
  TextParser({List<TextMatcher> matchers}) {
    this.matchers = matchers;
  }

  _Matchers _matchers;

  List<TextMatcher> get matchers => List.unmodifiable(_matchers.list);

  /// A setter for updating the list of matchers
  set matchers(List<TextMatcher> matchers) =>
      _matchers = _Matchers(matchers ?? _kDefaultMatchers);

  /// Parses the provided [text] according to the matchers specified in
  /// the constructor.
  ///
  /// If [useIsolate] is set to `true` or omitted, parsing is executed in
  /// an isolate except on the web where isolates are not supported,
  Future<List<TextElement>> parse(String text, {bool useIsolate = true}) async {
    if (!useIsolate || _kIsWeb) {
      return _Parser.exec(_matchers, text);
    }

    final completer = Completer<List<TextElement>>();
    final receivePort = ReceivePort();

    receivePort.listen((dynamic message) {
      if (message is SendPort) {
        message.send(_matchers);
        message.send(text);
        return;
      }
      completer.complete(message as List<TextElement>);
      receivePort.close();
    });

    await Isolate.spawn(_Parser.execInIsolate, receivePort.sendPort);

    return completer.future;
  }
}

class _Matchers {
  _Matchers(this.list) {
    _pattern = {
      for (var i = 0; i < list.length; i++)
        '(?<$_kNamedGroupPrefix$i>${list[i].pattern})',
    }.join('|');

    final groupCounts = list
        .map((v) => RegExp('${v.pattern}|.*').firstMatch('')?.groupCount)
        .toList();

    for (var i = 0; i < list.length; i++) {
      final start = i + groupCounts.sublist(0, i).fold<int>(1, (a, b) => a + b);
      final range = List.generate(groupCounts[i], (i) => start + i + 1);
      _groupRanges.add(range);
    }
  }

  final List<TextMatcher> list;
  String _pattern;
  final List<List<int>> _groupRanges = [];

  String get pattern => _pattern;
  List<List<int>> get groupRanges => _groupRanges;
}

class _Parser {
  static Future<List<TextElement>> exec(_Matchers matchers, String text) async {
    // Avoids blocking the UI (for use in Flutter).
    // https://github.com/flutter/flutter/blob/978a2e7bf6a2ed287130af8dbd94cef019fb7bef/packages/flutter/lib/src/foundation/_isolates_web.dart#L9-L12
    await null;
    return _parse(matchers, text);
  }

  static void execInIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    _Matchers matchers;
    receivePort.listen((dynamic message) {
      if (message is _Matchers) {
        matchers = message;
      }
      if (message is String) {
        final list = _parse(matchers, message);
        sendPort.send(list);
        receivePort.close();
      }
    });
  }

  static List<TextElement> _parse(_Matchers matchers, String text) {
    final regExp = RegExp(matchers.pattern);

    final list = <TextElement>[];
    var target = text;

    // Using concatenated patterns showed better performance than searching
    // with each pattern per iteration of do-while.
    do {
      final match = regExp.firstMatch(target);
      if (match == null) {
        list.add(_Element(target));
        target = '';
        break;
      }

      if (match.start > 0) {
        final v = target.substring(0, match.start);
        list.add(_Element(v));
      }

      for (var i = 0; i < matchers.list.length; i++) {
        final v = match.namedGroup('$_kNamedGroupPrefix$i');
        if (v != null) {
          list.add(
            _Element(
              v,
              groups: match.groups(matchers.groupRanges[i]),
              matcherType: matchers.list[i].runtimeType,
            ),
          );
          break;
        }
      }

      target = target.substring(match.end);
    } while (target.isNotEmpty);

    return list;
  }
}
