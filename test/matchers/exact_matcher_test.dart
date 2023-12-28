import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

extension on ExactMatcher {
  RegExp toRegExp() {
    return RegExp(pattern);
  }
}

void main() {
  test('Strings using reserved characters match exactly same strings', () {
    const input = 'Assembly BASIC C++? Dart (^*^)/';
    final regExp = ExactMatcher(const ['(^*^)/', 'C++?']).toRegExp();
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(2));
    expect(input.substring(matches[0].start, matches[0].end), 'C++?');
    expect(input.substring(matches[1].start, matches[1].end), '(^*^)/');
  });

  test('Reserved characters are escaped and used as ordinary characters', () {
    const input = 'ABCDEF AB.DE+';
    final regExp = ExactMatcher(const ['B.D', 'E+']).toRegExp();
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(2));
    expect(input.substring(matches[0].start, matches[0].end), 'B.D');
    expect(input.substring(matches[1].start, matches[1].end), 'E+');
  });
}
