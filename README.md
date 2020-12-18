# text_parser

[![Pub Version](https://img.shields.io/pub/v/text_parser)](https://pub.dev/packages/text_parser)
[![Dart CI](https://github.com/kaboc/dart_text_parser/workflows/Dart%20CI/badge.svg](https://github.com/kaboc/dart_text_parser/actions)

A Dart package for parsing text flexibly according to preset or custom regular expression patterns.

## Usage

### Using preset matchers (URL / email address / phone number)

If [matchers][TextParser_matchers] is omitted in [TextParser][TextParser], the three preset
matchers ([UrlMatcher][UrlMatcher], [EmailMatcher][EmailMatcher] and [TelMatcher][TelMatcher])
are used automatically.

The default regular expression pattern of each of them is not very strict.
If it is unsuitable for your use case, overwrite the pattern by yourself, referring to the
description in a later section of this document.

```dart
import 'package:text_parser/text_parser.dart';

Future<void> main() async {
  final parser = TextParser();
  final elements = await parser.parse(
    'abc https://example.com/sample.jpg. def\n'
    'foo@example.com +1-012-3456-7890',
  );
  elements.forEach(print);
}
```

Output:
```
matcherType: TextMatcher, text: abc , groups: []
matcherType: UrlMatcher, text: https://example.com/sample.jpg, groups: []
matcherType: TextMatcher, text: . def\n, groups: []
matcherType: EmailMatcher, text: foo@example.com, groups: []
matcherType: TextMatcher, text:  , groups: []
matcherType: TelMatcher, text: +1-012-3456-7890, groups: []
```

### Overwriting the pattern of a preset matcher

If you want to parse only URLs and phone numbers, but treat only a sequence of eleven numbers
after "tel:" as a phone number:

```dart
final parser = TextParser(
  matchers: const [
    UrlMatcher(),
    TelMatcher(r'(?<=tel:)\d{11}'),
  ],
);
```

If the match patterns of multiple matchers have matched the same string at the same position
in text, the first matcher is used for parsing the element.

### Using a custom matcher

You can create a custom matcher easily by extending [TextMatcher][TextMatcher].
The following is a matcher for links of the Markdown format like `[text](link_such_as_url_or_path)`.

```dart
class MdLinkMatcher extends TextMatcher {
  const MdLinkMatcher() : super(r'\[(.+?)\]\((.+?)\)');
}

...

final parser = TextParser(
  matchers: const [MdLinkMatcher()],
);
final elements = await parser.parse('abcde[foo](bar)fghij');
elements.forEach(print);
```

Output:
```
matcherType: TextMatcher, text: abcde, groups: []
matcherType: MdLinkMatcher, text: [foo](bar), groups: [foo, bar]
matcherType: TextMatcher, text: fghij, groups: []
```

#### Groups

Each [TextElement][TextElement] in a parse result has the property of
[groups][TextElement_groups]. It is an array of strings that have matched the smaller pattern
inside every set of parentheses `( )`.

To give the above code as an example, there are two sets of parentheses in the above example;
`(.+?)` in `\[(.+?)\]` and `\((.+?)\)`. They match "foo" and "bar" respectively, so they are
added to the array in that order.

Tip:

If you want certain parentheses to be not captured as a group, add `?:` after the starting
parenthesis, like `(?:pattern)` instead of `(pattern)`.

## Limitations

- Parsing is not executed in an isolate but in the main thread on the web, which
[dart:isolate][isolate] does not support.
- It may take seconds to parse a very long string with multiple complex match patterns.

## Troubleshooting

### Positive lookbehind sometimes does not work.

e.g.
- Text to be parsed
    - `'123abc456'`
- Match pattern 1
    - `r'\d+'`
        - Any sequence of numeric values
- Match pattern 2
    - `r'(?<=\d)[a-z]+'`
        - Alphabets after a number

In the above example, you may expect the first match to be "123" and the next match to be
"abc", but the second match is actually "456".

This is due to the mechanism of this package that excludes already searched parts of text
in later search iterations; "123" is found in the first iteration, and then the next
iteration is targeted at "abc456", which does not match `(?<=\d)`.

An easy solution is to have the positive lookbehind see `^` in addition to `\d`, like
`(?<=\d|^)`.

[TextParser]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser-class.html
[TextParser_matchers]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/matchers.html
[TextMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TextMatcher-class.html
[UrlMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlMatcher-class.html
[EmailMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/EmailMatcher-class.html
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher-class.html
[TextElement]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement-class.html
[TextElement_groups]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement/groups.html
[isolate]: https://api.dartlang.org/stable/dart-isolate/dart-isolate-library.html
