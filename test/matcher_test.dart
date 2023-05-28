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
      expect(parser.matchers[0], equals(const EmailMatcher()));
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

    test('Having matcher containing empty pattern throws AssertionError', () {
      expect(
        () => TextParser(matchers: const [EmailMatcher(), PatternMatcher('')]),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains('must have a non-empty pattern'),
          ),
        ),
      );
    });
  });
}
