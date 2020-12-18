import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  group('matcher', () {
    test('default pattern can be overwritten', () async {
      const pattern = 'pattern';
      const matcher = UrlMatcher(pattern);
      expect(matcher.pattern, equals(pattern));
    });

    test('matcher objects with same type and pattern are equal', () async {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher();
      expect(matcher1, equals(matcher2));
    });

    test('matcher objects with different patterns are not equal', () async {
      const matcher1 = UrlMatcher();
      const matcher2 = UrlMatcher('pattern');
      expect(matcher1, isNot(equals(matcher2)));
    });

    test('matcher objects with different types are not equal', () async {
      const pattern = 'pattern';
      const matcher1 = UrlMatcher(pattern);
      const matcher2 = EmailMatcher(pattern);
      expect(matcher1, isNot(equals(matcher2)));
    });
  });

  group('element', () {
    test('element objects with same text and matcherType are equal', () async {
      const element1 = _Element('text', groups: [], matcherType: UrlMatcher);
      const element2 = _Element('text', groups: [], matcherType: UrlMatcher);
      expect(element1, equals(element2));
    });

    test('element objects with different text or matcherType are not equal',
        () async {
      const element1 = _Element('text', groups: [], matcherType: UrlMatcher);
      const element2 = _Element('text1', groups: [], matcherType: UrlMatcher);
      const element3 = _Element('text', groups: [], matcherType: EmailMatcher);
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
  }) : super(text, groups, matcherType);
}
