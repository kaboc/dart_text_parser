import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  late TextParser parser;
  setUp(() {
    parser = TextParser();
  });

  test('matchers can be updated via matchers setter', () {
    expect(parser.matchers, hasLength(3));

    parser.matchers = const [EmailMatcher()];
    expect(parser.matchers, hasLength(1));
    expect(parser.matchers[0], equals(const EmailMatcher()));
  });

  group('parse', () {
    test('parses text correctly', () async {
      final elements = await parser.parse(
        'abc https://example.com/sample.jpg. def\n'
        'foo@example.com 911',
      );

      expect(elements, hasLength(6));
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
      parser.matchers = const [_MyTelMatcher()];
      final elements = await parser.parse('abc012(3456)7890def');
      expect(elements[0].text, equals('abc'));
      expect(elements[1].text, equals('012(3456)7890'));
      expect(elements[1].groups, equals(['012', '3456', '7890']));
      expect(elements[2].text, equals('def'));
    });

    test('named groups are caught correctly', () async {
      parser.matchers = const [
        PatternMatcher(r'(?<year>\d{4})-(?<month>\d{1,2})-(?<day>\d{1,2})'),
      ];
      final elements = await parser.parse('abc2022-01-23def');
      expect(elements[0].text, equals('abc'));
      expect(elements[1].text, equals('2022-01-23'));
      expect(elements[1].groups, equals(['2022', '01', '23']));
      expect(elements[2].text, equals('def'));
    });

    test('offsets are set correctly when onlyMatches is false', () async {
      const text =
          'abc https://example.com/sample.jpg. def\nfoo@example.com 911';
      final elements = await parser.parse(text);
      expect(elements, hasLength(6));

      var result = '';
      for (final elm in elements) {
        // ignore: use_string_buffers
        result += text.substring(elm.offset, elm.offset + elm.text.length);
      }
      expect(result, equals(text));
    });

    test('offsets are set correctly when onlyMatches is true', () async {
      const text =
          'abc https://example.com/sample.jpg. def\nfoo@example.com 911';
      final elements = await parser.parse(text, onlyMatches: true);
      expect(elements, hasLength(3));

      for (final elm in elements) {
        expect(elm.offset, equals(text.indexOf(elm.text)));
      }
    });

    test('parsing in main thread and in isolate give same result', () async {
      const text = 'https://example.com/ foo@example.com012-3456-7890';

      // ignore: avoid_redundant_argument_values
      final elements1 = await parser.parse(text, useIsolate: true);
      final elements2 = await parser.parse(text, useIsolate: false);

      expect(elements1[0].text, equals('https://example.com/'));
      expect(elements1[0].matcherType, equals(UrlMatcher));
      expect(elements1[1].text, equals(' '));
      expect(elements1[1].matcherType, equals(TextMatcher));
      expect(elements1[2].text, equals('foo@example.com'));
      expect(elements1[2].matcherType, equals(EmailMatcher));
      expect(elements1[3].text, equals('012-3456-7890'));
      expect(elements1[3].matcherType, equals(TelMatcher));

      expect(elements1, hasLength(elements2.length));

      for (var i = 0; i < elements1.length; i++) {
        expect(elements1[i], equals(elements2[i]));
      }
    });
  });

  group('options', () {
    test('dotAll', () async {
      const text = 'aaa // bbb\nccc';

      var elements = await TextParser(
        matchers: [const _LineCommentMatcher1()],
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, equals('// bbb'));

      elements = await TextParser(
        matchers: [const _LineCommentMatcher1()],
        dotAll: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, equals('// bbb\nccc'));
    });

    test('multiline', () async {
      const text = 'aaa // bbb\nccc';

      var elements = await TextParser(
        matchers: [const _LineCommentMatcher1()],
        dotAll: true,
        multiLine: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, equals('// bbb\nccc'));

      elements = await TextParser(
        matchers: [const _LineCommentMatcher2()],
        dotAll: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, equals('// bbb\nccc'));

      elements = await TextParser(
        matchers: [const _LineCommentMatcher2()],
        dotAll: true,
        multiLine: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, equals('// bbb'));
    });

    test('caseSensitive', () async {
      const text = 'aaa // BBB\ncCc';

      var elements = await TextParser(matchers: [const _AlphabetsMatcher()])
          .parse(text, onlyMatches: true);
      expect(elements.map((v) => v.text).toList(), equals(['aaa', 'c', 'c']));

      elements = await TextParser(
        matchers: [const _AlphabetsMatcher()],
        caseSensitive: false,
      ).parse(text, onlyMatches: true);
      expect(
        elements.map((v) => v.text).toList(),
        equals(['aaa', 'BBB', 'cCc']),
      );
    });

    test('unicode', () async {
      const text = 'abc123def';

      var elements = await TextParser(matchers: [const _UnicodeMatcher()])
          .parse(text, onlyMatches: true);
      expect(elements, isEmpty);

      elements =
          await TextParser(matchers: [const _UnicodeMatcher()], unicode: true)
              .parse(text, onlyMatches: true);
      expect(elements[0].text, equals('123'));
    });
  });
}

class _MyTelMatcher extends TextMatcher {
  const _MyTelMatcher() : super(r'(\d{3})\((\d{4})\)(\d{4})');
}

class _LineCommentMatcher1 extends TextMatcher {
  const _LineCommentMatcher1() : super(r'//.*');
}

class _LineCommentMatcher2 extends TextMatcher {
  const _LineCommentMatcher2() : super(r'//.*?$');
}

class _AlphabetsMatcher extends TextMatcher {
  const _AlphabetsMatcher() : super(r'[a-z]+');
}

class _UnicodeMatcher extends TextMatcher {
  const _UnicodeMatcher() : super(r'\p{N}+');
}
