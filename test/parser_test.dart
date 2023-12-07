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

  group('parse', () {
    test('parsing is skipped if text is empty', () async {
      final stopwatch = Stopwatch()..start();

      // ignore: avoid_redundant_argument_values
      final elements = await parser.parse('', useIsolate: true);

      stopwatch.stop();
      expect(elements, isEmpty);

      // Parsing in isolate usually takes longer than 10000 microseconds.
      expect(stopwatch.elapsedMicroseconds, lessThan(1000));
    });

    test('parsed correctly with default matchers', () async {
      final elements = await parser.parse(
        // "john.doe" in the email address is parsed as URL
        // mistakenly if UrlMatcher is specified before
        // EmailMatcher in the list of default matchers.
        'abc https://example.com/sample.jpg. def\n'
        'john.doe@example.com 911',
      );

      expect(elements, hasLength(6));
      expect(elements[0].text, 'abc ');
      expect(elements[0].offset, 0);
      expect(elements[0].groups, isEmpty);
      expect(elements[0].matcherType, TextMatcher);
      expect(elements[1].text, 'https://example.com/sample.jpg');
      expect(elements[1].offset, 4);
      expect(elements[1].groups, isEmpty);
      expect(elements[1].matcherType, UrlMatcher);
      expect(elements[2].text, '. def\n');
      expect(elements[2].offset, 34);
      expect(elements[2].groups, isEmpty);
      expect(elements[2].matcherType, TextMatcher);
      expect(elements[3].text, 'john.doe@example.com');
      expect(elements[3].offset, 40);
      expect(elements[3].groups, isEmpty);
      expect(elements[3].matcherType, EmailMatcher);
      expect(elements[4].text, ' ');
      expect(elements[4].offset, 60);
      expect(elements[4].groups, isEmpty);
      expect(elements[4].matcherType, TextMatcher);
      expect(elements[5].text, '911');
      expect(elements[5].offset, 61);
      expect(elements[5].groups, isEmpty);
      expect(elements[5].matcherType, TelMatcher);
    });

    test('parsed into a single element if there is no match', () async {
      final elements = await parser.parse('abcde');

      expect(elements, hasLength(1));
      expect(elements[0].text, 'abcde');
      expect(elements[0].offset, 0);
      expect(elements[0].groups, isEmpty);
      expect(elements[0].matcherType, TextMatcher);
    });

    test('elements have correct matcherIndex', () async {
      final elements = await TextParser(
        matchers: const [
          PatternMatcher('pattern1'),
          PatternMatcher('pattern2'),
          PatternMatcher('pattern3'),
        ],
      ).parse('pattern3pattern1');

      expect(elements, hasLength(2));
      expect(elements[0].text, 'pattern3');
      expect(elements[0].offset, 0);
      expect(elements[0].matcherType, PatternMatcher);
      expect(elements[0].matcherIndex, 2);
      expect(elements[1].text, 'pattern1');
      expect(elements[1].offset, 8);
      expect(elements[1].matcherType, PatternMatcher);
      expect(elements[1].matcherIndex, 0);
    });

    test('groups are caught correctly', () async {
      parser.matchers = const [_GroupingTelMatcher()];
      final elements = await parser.parse('abc012(3456)7890def');
      expect(elements[0].text, 'abc');
      expect(elements[0].groups, isEmpty);
      expect(elements[1].text, '012(3456)7890');
      expect(elements[1].groups, ['012', '3456', '7890']);
      expect(elements[2].text, 'def');
      expect(elements[2].groups, isEmpty);
    });

    test('named groups are caught correctly', () async {
      parser.matchers = const [
        PatternMatcher(r'(?<year>\d{4})-(?<month>\d{1,2})-(?<day>\d{1,2})'),
      ];
      final elements = await parser.parse('abc2022-01-23def');
      expect(elements[0].text, 'abc');
      expect(elements[0].groups, isEmpty);
      expect(elements[1].text, '2022-01-23');
      expect(elements[1].groups, ['2022', '01', '23']);
      expect(elements[2].text, 'def');
      expect(elements[2].groups, isEmpty);
    });

    test(
      'complex patterns with no group, unnamed and named groups work correctly',
      () async {
        parser.matchers = const [
          _GroupingTelMatcher(),
          UrlMatcher('(https?)://([a-z]+.[a-z]+)/'),
          // This matcher uses both unnamed and named groups.
          PatternMatcher(r'(?<year>\d{4})-(\d{1,2})-(?<day>\d{1,2})'),
        ];
        final elements = await parser.parse(
          'abc012(3456)7890def https://example.com/ 2022-01-23',
        );
        expect(elements[0].text, 'abc');
        expect(elements[0].groups, isEmpty);
        expect(elements[1].text, '012(3456)7890');
        expect(elements[1].groups, ['012', '3456', '7890']);
        expect(elements[2].text, 'def ');
        expect(elements[2].groups, isEmpty);
        expect(elements[3].text, 'https://example.com/');
        expect(elements[3].groups, ['https', 'example.com']);
        expect(elements[4].text, ' ');
        expect(elements[4].groups, isEmpty);
        expect(elements[5].text, '2022-01-23');
        expect(elements[5].groups, ['2022', '01', '23']);
      },
    );

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
      expect(result, text);
    });

    test('offsets are set correctly when onlyMatches is true', () async {
      const text =
          'abc https://example.com/sample.jpg. def\nfoo@example.com 911';
      final elements = await parser.parse(text, onlyMatches: true);
      expect(elements, hasLength(3));

      for (final elm in elements) {
        expect(elm.offset, text.indexOf(elm.text));
      }
    });

    // https://github.com/kaboc/dart_text_parser/pull/8
    test(
      'lookbehind assertion matches string right next to previous match.',
      () async {
        const text = 'abc123def';
        final elements = await TextParser(
          matchers: const [
            _AlphabetsMatcher(),
            PatternMatcher(r'(?<=[a-z])\d+'),
          ],
        ).parse(text);

        expect(elements[0].text, 'abc');
        expect(elements[0].matcherType, _AlphabetsMatcher);
        expect(elements[0].offset, 0);
        expect(elements[1].text, '123');
        expect(elements[1].matcherType, PatternMatcher);
        expect(elements[1].offset, 3);
        expect(elements[2].text, 'def');
        expect(elements[2].matcherType, _AlphabetsMatcher);
        expect(elements[2].offset, 6);
      },
    );

    test('parsing in main thread and in isolate give same result', () async {
      const text = 'https://example.com/ foo@example.com012-3456-7890';

      final results = await Future.wait([
        // ignore: avoid_redundant_argument_values
        parser.parse(text, useIsolate: true),
        parser.parse(text, useIsolate: false),
      ]);
      final elements1 = results[0];
      final elements2 = results[1];

      expect(elements1[0].text, 'https://example.com/');
      expect(elements1[0].matcherType, UrlMatcher);
      expect(elements1[1].text, ' ');
      expect(elements1[1].matcherType, TextMatcher);
      expect(elements1[2].text, 'foo@example.com');
      expect(elements1[2].matcherType, EmailMatcher);
      expect(elements1[3].text, '012-3456-7890');
      expect(elements1[3].matcherType, TelMatcher);

      expect(elements1, hasLength(elements2.length));

      for (var i = 0; i < elements1.length; i++) {
        expect(elements1[i], elements2[i]);
      }
    });
  });

  group('options', () {
    test('dotAll', () async {
      const text = 'aaa // bbb\nccc';

      var elements = await TextParser(
        matchers: [const _LineCommentMatcher1()],
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, '// bbb');

      elements = await TextParser(
        matchers: [const _LineCommentMatcher1()],
        dotAll: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, '// bbb\nccc');
    });

    test('multiline', () async {
      const text = 'aaa // bbb\nccc';

      var elements = await TextParser(
        matchers: [const _LineCommentMatcher1()],
        dotAll: true,
        multiLine: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, '// bbb\nccc');

      elements = await TextParser(
        matchers: [const _LineCommentMatcher2()],
        dotAll: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, '// bbb\nccc');

      elements = await TextParser(
        matchers: [const _LineCommentMatcher2()],
        dotAll: true,
        multiLine: true,
      ).parse(text, onlyMatches: true);
      expect(elements[0].text, '// bbb');
    });

    test('caseSensitive', () async {
      const text = 'aaa // BBB\ncCc';

      var elements = await TextParser(matchers: [const _AlphabetsMatcher()])
          .parse(text, onlyMatches: true);
      expect(elements.map((v) => v.text).toList(), ['aaa', 'c', 'c']);

      elements = await TextParser(
        matchers: [const _AlphabetsMatcher()],
        caseSensitive: false,
      ).parse(text, onlyMatches: true);
      expect(
        elements.map((v) => v.text).toList(),
        ['aaa', 'BBB', 'cCc'],
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
      expect(elements[0].text, '123');
    });
  });
}

class _GroupingTelMatcher extends TextMatcher {
  const _GroupingTelMatcher() : super(r'(\d{3})\((\d{4})\)(\d{4})');
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
