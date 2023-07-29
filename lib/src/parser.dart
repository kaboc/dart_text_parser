import 'element.dart';
import 'matcher.dart';

const _kMatcherGroupPrefix = '__mg__';

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
  final List<String> _matcherGroupNames = [];
  final List<List<int>> _matcherGroupRanges = [];
  late String _pattern;

  List<TextMatcher> get matchers => List.unmodifiable(_matchers);

  void update(List<TextMatcher> matchers) {
    assert(
      matchers.isNotEmpty,
      'At least one matcher must not specified.',
    );

    _matchers = matchers;
    _matcherGroupNames.clear();
    _matcherGroupRanges.clear();

    var groupIndexStart = 2;
    for (var i = 0; i < matchers.length; i++) {
      assert(
        matchers[i].pattern.isNotEmpty,
        'All matchers must have a non-empty pattern.',
      );

      _matcherGroupNames.add('$_kMatcherGroupPrefix$i');

      final regExp = RegExp(
        '${matchers[i].pattern}|.*',
        multiLine: multiLine,
        caseSensitive: caseSensitive,
        unicode: unicode,
        dotAll: dotAll,
      );
      final groupCount = regExp.firstMatch('')?.groupCount ?? 0;

      _matcherGroupRanges.add([
        for (var i = 0; i < groupCount; i++) groupIndexStart + i,
      ]);

      groupIndexStart += groupCount + 1;
    }

    _pattern = {
      for (var i = 0; i < matchers.length; i++)
        '(?<${_matcherGroupNames[i]}>${matchers[i].pattern})',
    }.join('|');
  }

  List<TextElement> parse(String text, {required bool onlyMatches}) {
    final regExp = RegExp(
      _pattern,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      unicode: unicode,
      dotAll: dotAll,
    );
    final matches = regExp.allMatches(text);

    final list = <TextElement>[];
    var offset = 0;

    for (final match in matches) {
      if (!onlyMatches && match.start > offset) {
        final substring = text.substring(offset, match.start);
        list.add(TextElement(substring, offset: offset));
      }

      final substring = text.substring(match.start, match.end);
      final matcherIndex = _matcherGroupNames
          .indexWhere((name) => match.namedGroup(name) == substring);

      if (matcherIndex > -1) {
        list.add(
          TextElement(
            substring,
            offset: match.start,
            matcherType: matchers[matcherIndex].runtimeType,
            matcherIndex: matcherIndex,
            groups: match.groups(_matcherGroupRanges[matcherIndex]),
          ),
        );
      }

      offset = match.end;
    }

    if (!onlyMatches && offset < text.length) {
      final substring = text.substring(offset);
      list.add(TextElement(substring, offset: offset));
    }

    return list;
  }
}
