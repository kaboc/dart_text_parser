import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  group('matcher', () {
    test('default pattern can be overwritten', () {
      const pattern = 'pattern';
      const matcher = UrlMatcher(pattern);
      expect(matcher.pattern, equals(pattern));
    });

    test('PatternMatcher', () {
      const matcher = PatternMatcher('abc');
      expect(matcher, isA<TextMatcher>());
      expect(matcher.toString(), equals('PatternMatcher(pattern: abc)'));
    });

    test('matcher objects with same type and pattern are equal', () {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher();
      expect(matcher1, equals(matcher2));
    });

    test('matcher objects with different patterns are not equal', () {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher('pattern');
      expect(matcher1, isNot(equals(matcher2)));
    });

    test('matcher objects with different types are not equal', () {
      const pattern = 'pattern';
      const matcher1 = UrlMatcher(pattern);
      const matcher2 = EmailMatcher(pattern);
      expect(matcher1, isNot(equals(matcher2)));
    });
  });

  group('element', () {
    test('element objects with same values in all properties are equal', () {
      const element1 = _Element(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element2 = _Element(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      expect(element1, equals(element2));
    });

    test('elements with different value in any property are not equal', () {
      const element1 = _Element(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element2 = _Element(
        'texu',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element3 = _Element(
        'text',
        groups: ['te', 'xu'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element4 = _Element(
        'text',
        groups: ['xt', 'te'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element5 = _Element(
        'text',
        groups: ['te', 'xt'],
        matcherType: EmailMatcher,
        offset: 10,
      );
      const element6 = _Element(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 11,
      );
      expect(element1, isNot(equals(element2)));
      expect(element1, isNot(equals(element3)));
      expect(element1, isNot(equals(element4)));
      expect(element1, isNot(equals(element5)));
      expect(element1, isNot(equals(element6)));
    });
  });
}

class _Element extends TextElement {
  const _Element(
    String text, {
    List<String?> groups = const [],
    Type matcherType = TextMatcher,
    int offset = 0,
  }) : super(text, groups, matcherType, offset);
}
