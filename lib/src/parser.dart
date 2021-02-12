import 'package:meta/meta.dart';

import 'element.dart';
import 'matcher.dart';

const _kNamedGroupPrefix = 'ng';

class Parser {
  Parser({@required List<TextMatcher> matchers}) {
    update(matchers);
  }

  List<TextMatcher> _matchers;
  String _pattern;
  final List<List<int>> _groupRanges = [];

  List<TextMatcher> get matchers => List.unmodifiable(_matchers);

  void update(List<TextMatcher> matchers) {
    assert(matchers != null);

    _matchers = matchers;

    // Using a concatenated pattern showed better performance than
    // iterating each pattern.
    _pattern = {
      for (var i = 0; i < matchers.length; i++)
        '(?<$_kNamedGroupPrefix$i>${matchers[i].pattern})',
    }.join('|');

    final groupCounts = matchers
        .map((v) => RegExp('${v.pattern}|.*').firstMatch('')?.groupCount ?? 0)
        .toList();

    _groupRanges.clear();
    for (var i = 0; i < matchers.length; i++) {
      final start = i + groupCounts.sublist(0, i).fold<int>(1, (a, b) => a + b);
      final range = List.generate(groupCounts[i], (i) => start + i + 1);
      _groupRanges.add(range);
    }
  }

  List<TextElement> parse(String text, bool onlyMatches) {
    final regExp = RegExp(_pattern);
    final list = <TextElement>[];
    var target = text;

    do {
      final match = regExp.firstMatch(target);
      if (match == null) {
        if (!onlyMatches) {
          list.add(_Element(target));
        }
        target = '';
        break;
      }

      if (match.start > 0) {
        final v = target.substring(0, match.start);
        if (!onlyMatches) {
          list.add(_Element(v));
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

class _Element extends TextElement {
  const _Element(
    String text, {
    List<String> groups,
    Type matcherType,
  }) : super(
          text,
          groups ?? const [],
          matcherType ?? TextMatcher,
        );
}
