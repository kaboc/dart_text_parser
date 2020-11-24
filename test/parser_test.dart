import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  TextParser parser;
  setUp(() {
    parser = TextParser();
  });

  test('matchers can be updated via matchers setter', () async {
    expect(parser.matchers.length, equals(3));

    parser.matchers = const [EmailMatcher()];
    expect(parser.matchers.length, equals(1));
    expect(parser.matchers[0], equals(const EmailMatcher()));
  });

  group('parse', () {
    test('parses text correctly', () async {
      final elements = await parser.parse(
        'abc https://example.com/sample.jpg. def\n'
        'foo@example.com 911',
      );

      expect(elements.length, equals(6));
      expect(elements[0].text, equals('abc '));
      expect(elements[0].groups, equals(<String>[]));
      expect(elements[0].matcherType, equals(TextMatcher));
      expect(elements[1].text, equals('https://example.com/sample.jpg'));
      expect(elements[1].groups, equals(<String>[]));
      expect(elements[1].matcherType, equals(UrlMatcher));
      expect(elements[2].text, equals('. def\n'));
      expect(elements[2].groups, equals(<String>[]));
      expect(elements[2].matcherType, equals(TextMatcher));
      expect(elements[3].text, equals('foo@example.com'));
      expect(elements[3].groups, equals(<String>[]));
      expect(elements[3].matcherType, equals(EmailMatcher));
      expect(elements[4].text, equals(' '));
      expect(elements[4].groups, equals(<String>[]));
      expect(elements[4].matcherType, equals(TextMatcher));
      expect(elements[5].text, equals('911'));
      expect(elements[5].groups, equals(<String>[]));
      expect(elements[5].matcherType, equals(TelMatcher));
    });

    test('groups are caught correctly', () async {
      parser.matchers = const [_MdLinkMatcher()];
      final elements = await parser.parse('abc [foo](bar) def');
      expect(elements[1].groups, equals(['foo', 'bar']));
    });
  });
}

class _MdLinkMatcher extends TextMatcher {
  const _MdLinkMatcher() : super(r'(?<=\s)\[(.+?)\]\((.+?)\)(?=\s)');
}
