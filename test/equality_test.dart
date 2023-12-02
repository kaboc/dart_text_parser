import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  group('equality of matchers', () {
    test('default pattern can be overwritten', () {
      const pattern = 'pattern';
      const matcher = UrlMatcher(pattern);
      expect(matcher.pattern, pattern);
    });

    test('PatternMatcher', () {
      const matcher = PatternMatcher('abc');
      expect(matcher, isA<TextMatcher>());
      expect(matcher.toString(), 'PatternMatcher(pattern: abc)');
    });

    test('matchers with same type and pattern are equal', () {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher();
      expect(matcher1, matcher2);
      expect(matcher1.hashCode, matcher2.hashCode);
    });

    test('matchers with different patterns are not equal', () {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher('pattern');
      expect(matcher1, isNot(matcher2));
      expect(matcher1.hashCode, isNot(matcher2.hashCode));
    });

    test('matchers with same pattern but different types are not equal', () {
      const pattern = 'pattern';
      const matcher1 = UrlMatcher(pattern);
      const matcher2 = EmailMatcher(pattern);
      expect(matcher1, isNot(matcher2));
      expect(matcher1.hashCode, isNot(matcher2.hashCode));
    });
  });

  group('equality of elements', () {
    test('element objects with same values in all properties are equal', () {
      const element1 = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element2 = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      expect(element1, element2);
      expect(element1.hashCode, element2.hashCode);
    });

    test('elements with different value in any property are not equal', () {
      const element1 = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element2 = TextElement(
        'texu',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element3 = TextElement(
        'text',
        groups: ['te', 'xu'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element4 = TextElement(
        'text',
        groups: ['xt', 'te'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const element5 = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: EmailMatcher,
        offset: 10,
      );
      const element6 = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 11,
      );
      expect(element1, isNot(element2));
      expect(element1, isNot(element3));
      expect(element1, isNot(element4));
      expect(element1, isNot(element5));
      expect(element1, isNot(element6));
      expect(element1.hashCode, isNot(element2.hashCode));
      expect(element1.hashCode, isNot(element3.hashCode));
      expect(element1.hashCode, isNot(element4.hashCode));
      expect(element1.hashCode, isNot(element5.hashCode));
      expect(element1.hashCode, isNot(element6.hashCode));
    });

    test('elements with same value but different types are not equal', () {
      const element1 = TextElement('text');
      const element2 = TextElementWithDifferentName('text');
      expect(element1, isNot(element2));
      expect(element1.hashCode, isNot(element2.hashCode));
    });
  });
}

class TextElementWithDifferentName extends TextElement {
  const TextElementWithDifferentName(super.text);
}
