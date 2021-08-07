import 'element.dart';
import 'matcher.dart';

const _kNamedGroupPrefix = 'ng';

class Parser {
  Parser({
    required List<TextMatcher> matchers,
    required this.multiLine,
    required this.caseSensitive,
    required this.unicode,
    required this.dotAll,
  }) {
    update(matchers);
  }

  final bool multiLine;
  final bool caseSensitive;
  final bool unicode;
  final bool dotAll;

  late List<TextMatcher> _matchers;
  late String _pattern;
  final List<List<int>> _groupRanges = [];

  List<TextMatcher> get matchers => List.unmodifiable(_matchers);

  void update(List<TextMatcher> matchers) {
    _matchers = matchers;

    // Using a concatenated pattern showed better performance than
    // iterating each pattern.
    _pattern = {
      for (var i = 0; i < matchers.length; i++)
        '(?<$_kNamedGroupPrefix$i>${matchers[i].pattern})',
    }.join('|');

    final groupCounts = matchers.map((v) {
      final regExp = RegExp(
        '${v.pattern}|.*',
        multiLine: multiLine,
        caseSensitive: caseSensitive,
        unicode: unicode,
        dotAll: dotAll,
      );
      return regExp.firstMatch('')?.groupCount ?? 0;
    }).toList();

    _groupRanges.clear();
    for (var i = 0; i < matchers.length; i++) {
      final start = i + groupCounts.sublist(0, i).fold<int>(1, (a, b) => a + b);
      final range = List.generate(groupCounts[i], (i) => start + i + 1);
      _groupRanges.add(range);
    }
  }

  List<TextElement> parse(String text, bool onlyMatches) {
    final regExp = RegExp(
      _pattern,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      unicode: unicode,
      dotAll: dotAll,
    );

    final list = <TextElement>[];
    var target = text;
    var prevOffset = 0;

    do {
      final match = regExp.firstMatch(target);
      if (match == null) {
        if (!onlyMatches) {
          list.add(_Element(target, offset: prevOffset));
        }
        break;
      }

      if (match.start > 0) {
        final v = target.substring(0, match.start);
        if (!onlyMatches) {
          list.add(_Element(v, offset: prevOffset));
        }
      }

      for (var i = 0; i < _matchers.length; i++) {
        final v = match.namedGroup('$_kNamedGroupPrefix$i');
        if (v != null) {
          list.add(
            _Element(
              v,
              groups: match.groups(_groupRanges[i]),
              matcherType: _matchers[i].runtimeType,
              offset: prevOffset + match.start,
            ),
          );
          break;
        }
      }

      target = target.substring(match.end);
      prevOffset += match.end;
    } while (target.isNotEmpty);

    return list;
  }
}

class _Element extends TextElement {
  const _Element(
    String text, {
    List<String?> groups = const [],
    Type matcherType = TextMatcher,
    int offset = 0,
  }) : super(text, groups, matcherType, offset);
}
