import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  group('copyWith()', () {
    test('copies with new text and groups', () {
      const element = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      final newElement = element.copyWith(text: 'text2', groups: ['te', 'xt2']);
      expect(newElement.text, equals('text2'));
      expect(newElement.groups, equals(['te', 'xt2']));
      expect(newElement.matcherType, equals(UrlMatcher));
      expect(newElement.offset, equals(10));
    });

    test('copies with new matcherType and offset', () {
      const element = TextElement(
        'text',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      final newElement = element.copyWith(matcherType: TelMatcher, offset: 20);
      expect(newElement.text, equals('text'));
      expect(newElement.groups, equals(['te', 'xt']));
      expect(newElement.matcherType, equals(TelMatcher));
      expect(newElement.offset, equals(20));
    });
  });

  group('toString()', () {
    test('returns correct string', () {
      const element = TextElement(
        'te\r\n\txt',
        groups: ['te', 'xt'],
        matcherType: UrlMatcher,
        offset: 10,
      );
      const expected = 'TextElement(matcherType: UrlMatcher, '
          r'offset: 10, text: te\r\n\txt, groups: [te, xt])';
      expect(element.toString(), equals(expected));
    });
  });

  group('extension methods', () {
    test('whereMatcherType()', () {
      const elements = [
        TextElement('text1'),
        TextElement('text2', matcherType: UrlMatcher),
        TextElement('text3', matcherType: UrlMatcher),
        TextElement('text4', matcherType: EmailMatcher),
        TextElement('text5', matcherType: UrlMatcher),
        TextElement('text6'),
      ];
      expect(elements.whereMatcherType<TextMatcher>(), hasLength(2));
      expect(elements.whereMatcherType<EmailMatcher>(), hasLength(1));
      expect(
        elements.whereMatcherType<UrlMatcher>().map((e) => e.text),
        equals(['text2', 'text3', 'text5']),
      );
    });

    test('containsMatcherType()', () {
      const elements = [
        TextElement('text1', matcherType: UrlMatcher),
        TextElement('text2', matcherType: EmailMatcher),
        TextElement('text3', matcherType: UrlMatcher),
      ];
      expect(elements.containsMatcherType<EmailMatcher>(), isTrue);
      expect(elements.containsMatcherType<TextMatcher>(), isFalse);
      expect(elements.containsMatcherType<TelMatcher>(), isFalse);
    });

    test('reassignOffsets() without startingOffset', () {
      const elements = [
        TextElement('01234'),
        TextElement('5'),
        TextElement('678'),
        TextElement('9012'),
      ];
      final newElements = elements.reassignOffsets();

      expect(elements.map((e) => e.offset), [0, 0, 0, 0]);
      expect(newElements.map((e) => e.offset), [0, 5, 6, 9]);
    });

    test('reassignOffsets() with startingOffset', () {
      const elements = [
        TextElement('01234'),
        TextElement('5'),
        TextElement('678'),
        TextElement('9012'),
      ];
      final newElements = elements.reassignOffsets(startingOffset: 10);

      expect(elements.map((e) => e.offset), [0, 0, 0, 0]);
      expect(newElements.map((e) => e.offset), [10, 15, 16, 19]);
    });
  });
}