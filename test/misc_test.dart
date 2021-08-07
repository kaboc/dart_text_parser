import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  group('matcher', () {
    test('default pattern can be overwritten', () {
      const pattern = 'pattern';
      const matcher = UrlMatcher(pattern);
      expect(matcher.pattern, equals(pattern));
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
    test('element objects with same text and matcherType are equal', () {
      const element1 = _Element('text', matcherType: UrlMatcher);
      const element2 = _Element('text', matcherType: UrlMatcher);
      expect(element1, equals(element2));
    });

    test('elements with different text or matcherType are not equal', () {
      const element1 = _Element('text', matcherType: UrlMatcher);
      const element2 = _Element('text1', matcherType: UrlMatcher);
      const element3 = _Element('text', matcherType: EmailMatcher);
      expect(element1, isNot(equals(element2)));
      expect(element1, isNot(equals(element3)));
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
