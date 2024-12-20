import 'element.dart';
import 'matcher.dart';

const _kMatcherGroupPrefix = '__mg__';

class ParserBody {
  ParserBody({
    required Iterable<TextMatcher> matchers,
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

  late Iterable<TextMatcher> _matchers;
  late String _pattern;
  final List<String> _matcherGroupNames = [];
  final List<List<int>> _matcherGroupRanges = [];

  List<TextMatcher> get matchers => List.unmodifiable(_matchers);

  void update(Iterable<TextMatcher> matchers) {
    assert(
      matchers.isNotEmpty,
      'At least one matcher must not specified.',
    );

    _matchers = matchers;
    _matcherGroupNames.clear();
    _matcherGroupRanges.clear();

    var groupIndexStart = 2;
    final patterns = <String>[];

    for (final (i, element) in matchers.indexed) {
      final groupName = '$_kMatcherGroupPrefix$i';
      _matcherGroupNames.add(groupName);

      var pattern = element.pattern;
      if (pattern.isEmpty) {
        // Expression that does not match anything.
        pattern = '(?!)';
      }
      patterns.add('(?<$groupName>$pattern)');

      final regExp = RegExp(
        '$pattern|.*',
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

    _pattern = patterns.join('|');
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

  Future<List<TextElement>> parseAsync(
    String text, {
    required bool onlyMatches,
  }) async {
    // Avoids blocking the UI.
    // https://github.com/flutter/flutter/blob/978a2e7bf6a2ed287130af8dbd94cef019fb7bef/packages/flutter/lib/src/foundation/_isolates_web.dart#L9-L12
    await null;
    return parse(text, onlyMatches: onlyMatches);
  }
}
