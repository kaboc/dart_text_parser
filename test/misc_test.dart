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

    test('Creating matcher with empty pattern throws', () {
      expect(
        () => PatternMatcher(''),
        throwsA(isA<AssertionError>()),
      );
    });

    test('matchers with same type and pattern are equal', () {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher();
      expect(matcher1, equals(matcher2));
      expect(matcher1.hashCode, equals(matcher2.hashCode));
    });

    test('matchers with different patterns are not equal', () {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher('pattern');
      expect(matcher1, isNot(equals(matcher2)));
      expect(matcher1.hashCode, isNot(equals(matcher2.hashCode)));
    });

    test('matchers with same pattern but different types are not equal', () {
      const pattern = 'pattern';
      const matcher1 = UrlMatcher(pattern);
      const matcher2 = EmailMatcher(pattern);
      expect(matcher1, isNot(equals(matcher2)));
      expect(matcher1.hashCode, isNot(equals(matcher2.hashCode)));
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
      expect(element1.hashCode, equals(element2.hashCode));
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
      expect(element1.hashCode, isNot(equals(element2.hashCode)));
      expect(element1.hashCode, isNot(equals(element3.hashCode)));
      expect(element1.hashCode, isNot(equals(element4.hashCode)));
      expect(element1.hashCode, isNot(equals(element5.hashCode)));
      expect(element1.hashCode, isNot(equals(element6.hashCode)));
    });

    test('elements with same value but different types are not equal', () {
      const element1 = _Element('text');
      const element2 = _Element2('text');
      expect(element1, isNot(equals(element2)));
      expect(element1.hashCode, isNot(equals(element2.hashCode)));
    });

    test('toString() of TextElement returns correct string', () {
      const element = _Element(
        'te\r\n\txt',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      final expected = 'TextElement(matcherType: UrlMatcher, '
          r'offset: 10, text: te\r\n\txt, groups: [te, xt])';
      expect(element.toString(), equals(expected));
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

class _Element2 extends _Element {
  const _Element2(super.text);
}
