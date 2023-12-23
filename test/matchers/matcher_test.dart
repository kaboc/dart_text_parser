import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  late TextParser parser;
  setUp(() {
    parser = TextParser(
      matchers: const [
        EmailMatcher(),
        UrlMatcher(),
        TelMatcher(),
      ],
    );
  });

  group('matcher', () {
    test('matchers can be updated via matchers setter', () {
      expect(parser.matchers, hasLength(3));

      parser.matchers = const [EmailMatcher()];
      expect(parser.matchers, hasLength(1));
      expect(parser.matchers[0], const EmailMatcher());
    });

    test('Creating TextParser with no matcher throws AssertionError', () {
      expect(
        () => TextParser(matchers: []),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains('At least one matcher'),
          ),
        ),
      );
    });

    test('Replacing matchers with empty List throws AssertionError', () {
      expect(
        () => parser.matchers = [],
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains('At least one matcher'),
          ),
        ),
      );
    });

    test('correctly parsed with matchers containing empty pattern', () async {
      final parser = TextParser(
        matchers: const [
          PatternMatcher('(bbb)'),
          PatternMatcher(''),
          PatternMatcher('(ddd)'),
        ],
      );
      final elements = await parser.parse('aaabbbcccdddeee');

      expect(elements, hasLength(5));
      expect(elements[0], const TextElement('aaa'));
      expect(elements[0].matcherType, TextMatcher);
      expect(elements[0].matcherIndex, null);
      expect(elements[1].text, 'bbb');
      expect(elements[1].matcherType, PatternMatcher);
      expect(elements[1].matcherIndex, 0);
      expect(elements[1].groups, ['bbb']);
      expect(elements[2].text, 'ccc');
      expect(elements[2].matcherType, TextMatcher);
      expect(elements[2].matcherIndex, null);
      expect(elements[3].text, 'ddd');
      expect(elements[3].matcherType, PatternMatcher);
      expect(elements[3].matcherIndex, 2);
      expect(elements[3].groups, ['ddd']);
      expect(elements[4].text, 'eee');
      expect(elements[4].matcherType, TextMatcher);
      expect(elements[4].matcherIndex, null);
    });
  });
}
