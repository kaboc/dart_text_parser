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
      const expected = 'TextElement('
          'matcherType: UrlMatcher, '
          'matcherIndex: null, '
          'offset: 10, '
          r'text: te\r\n\txt, '
          'groups: [te, xt]'
          ')';
      expect(element.toString(), equals(expected));
    });
  });

  group('extension methods', () {
    test('whereMatcherType()', () {
      const elms = [
        TextElement('text1'),
        TextElement('text2', matcherType: UrlMatcher, matcherIndex: 0),
        TextElement('text3', matcherType: UrlMatcher, matcherIndex: 1),
        TextElement('text4', matcherType: TelMatcher, matcherIndex: 2),
        TextElement('text5', matcherType: UrlMatcher, matcherIndex: 1),
        TextElement('text6'),
      ];
      expect(elms.whereMatcherType<TextMatcher>(), hasLength(2));
      expect(elms.whereMatcherType<TelMatcher>(), hasLength(1));
      expect(
        elms.whereMatcherType<UrlMatcher>().map((e) => e.text),
        equals(['text2', 'text3', 'text5']),
      );
    });

    test('whereMatcherType(matcherIndex: ...)', () {
      const elms = [
        TextElement('text1'),
        TextElement('text2', matcherType: UrlMatcher, matcherIndex: 0),
        TextElement('text3', matcherType: UrlMatcher, matcherIndex: 1),
        TextElement('text4', matcherType: TelMatcher, matcherIndex: 2),
        TextElement('text5', matcherType: UrlMatcher, matcherIndex: 1),
        TextElement('text6'),
      ];

      final res = elms.whereMatcherType<UrlMatcher>(matcherIndex: 1);
      expect(res, hasLength(2));
      expect(res.map((e) => e.text), equals(['text3', 'text5']));
      expect(elms.whereMatcherType<TelMatcher>(matcherIndex: 0), isEmpty);
      expect(elms.whereMatcherType<TelMatcher>(matcherIndex: 2), hasLength(1));
    });

    test('containsMatcherType()', () {
      const elms = [
        TextElement('text1', matcherType: UrlMatcher, matcherIndex: 0),
        TextElement('text2', matcherType: TelMatcher, matcherIndex: 1),
        TextElement('text3', matcherType: UrlMatcher, matcherIndex: 0),
      ];
      expect(elms.containsMatcherType<EmailMatcher>(), isFalse);
      expect(elms.containsMatcherType<TextMatcher>(), isFalse);
      expect(elms.containsMatcherType<TelMatcher>(), isTrue);
    });

    test('containsMatcherType(matcherIndex: ...)', () {
      const elms = [
        TextElement('text1', matcherType: UrlMatcher, matcherIndex: 0),
        TextElement('text2', matcherType: TelMatcher, matcherIndex: 1),
        TextElement('text3', matcherType: UrlMatcher, matcherIndex: 0),
        TextElement('text4', matcherType: UrlMatcher, matcherIndex: 2),
      ];
      expect(elms.containsMatcherType<UrlMatcher>(matcherIndex: 0), isTrue);
      expect(elms.containsMatcherType<UrlMatcher>(matcherIndex: 1), isFalse);
      expect(elms.containsMatcherType<UrlMatcher>(matcherIndex: 2), isTrue);
    });

    test('reassignOffsets() without startingOffset', () {
      const elms = [
        TextElement('01234'),
        TextElement('5'),
        TextElement('678'),
        TextElement('9012'),
      ];
      final newElms = elms.reassignOffsets();

      expect(elms.map((e) => e.offset), [0, 0, 0, 0]);
      expect(newElms.map((e) => e.offset), [0, 5, 6, 9]);
    });

    test('reassignOffsets() with startingOffset', () {
      const elms = [
        TextElement('01234'),
        TextElement('5'),
        TextElement('678'),
        TextElement('9012'),
      ];
      final newElms = elms.reassignOffsets(startingOffset: 10);

      expect(elms.map((e) => e.offset), [0, 0, 0, 0]);
      expect(newElms.map((e) => e.offset), [10, 15, 16, 19]);
    });
  });
}
