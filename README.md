[![Pub Version](https://img.shields.io/pub/v/text_parser)](https://pub.dev/packages/text_parser)
[![Dart CI](https://github.com/kaboc/dart_text_parser/workflows/Dart%20CI/badge.svg)](https://github.com/kaboc/dart_text_parser/actions)
[![codecov](https://codecov.io/gh/kaboc/dart_text_parser/branch/main/graph/badge.svg?token=YTDF6ZVV3N)](https://codecov.io/gh/kaboc/dart_text_parser)

A Dart package for parsing text flexibly according to preset or custom regular expression patterns.

## Usage

### Using preset matchers (URL / email address / phone number)

If [matchers][TextParser_matchers] is omitted in [TextParser][TextParser], the three preset
matchers ([UrlMatcher][UrlMatcher], [EmailMatcher][EmailMatcher] and [TelMatcher][TelMatcher])
are used automatically.

The default regular expression pattern of each of them is not very strict.
If it is unsuitable for your use case, overwrite the pattern by yourself, referring to the
relevant section later in this document.

```dart
import 'package:text_parser/text_parser.dart';

Future<void> main() async {
  const text = 'abc https://example.com/sample.jpg. def\n'
      'foo@example.com +1-012-3456-7890';

  final parser = TextParser();
  final elements = await parser.parse(text);
  elements.forEach(print);
}
```

Output:

```
TextElement(matcherType: TextMatcher, offset: 0, text: abc , groups: [])
TextElement(matcherType: UrlMatcher, offset: 4, text: https://example.com/sample.jpg, groups: [])
TextElement(matcherType: TextMatcher, offset: 34, text: . def\n, groups: [])
TextElement(matcherType: EmailMatcher, offset: 40, text: foo@example.com, groups: [])
TextElement(matcherType: TextMatcher, offset: 55, text:  , groups: [])
TextElement(matcherType: TelMatcher, offset: 56, text: +1-012-3456-7890, groups: [])
```

### Extracting only matching text elements

By default, the result of [parse()][parse] contains both matching and non-matching elements
as seen in the above example. If you want only matching elements, set `onlyMatches` to `true`
when calling `parse()`.

```dart
final elements = await parser.parse(text, onlyMatches: true);
elements.forEach(print);
```

Output:

```
TextElement(matcherType: UrlMatcher, offset: 4, text: https://example.com/sample.jpg, groups: [])
TextElement(matcherType: EmailMatcher, offset: 40, text: foo@example.com, groups: [])
TextElement(matcherType: TelMatcher, offset: 56, text: +1-012-3456-7890, groups: [])
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

### Using a custom pattern

You can create a matcher with a custom pattern either with [PatternMatcher][PatternMatcher]
or by extending [TextMatcher][TextMatcher].

#### PatternMatcher

```dart
const boldMatcher = PatternMatcher(r'\*\*(.+)\*\*');
final parser = TextParser(matchers: [boldMatcher]);
```

#### Extending TextMatcher

Below is an example of a matcher that parses the HTML `<a>` tags into a set of the href
value and the link text.

```dart
class ATagMatcher extends TextMatcher {
  const ATagMatcher()
      : super(
          r'\<a\s(?:.+?\s)*?href="(.+?)".*?\>'
          r'\s*(.+?)\s*'
          r'\</a\>',
        );
}
```

```dart
const text = '''
<a class="foo" href="https://example.com/">
  Content inside tags
</a>
''';

final parser = TextParser(
  matchers: const [ATagMatcher()],
  dotAll: true,
);
final elements = await parser.parse(text, onlyMatches: true);
print(elements.first.groups);
```

Output:

```
[https://example.com/, Content inside tags]
```

### Groups

Each [TextElement][TextElement] in a parse result has the property of
[groups][TextElement_groups]. It is an array of strings that have matched the smaller pattern
inside every set of parentheses `( )`.

To give the above code as an example, there are two sets of parentheses; `(.+?)` in `\[(.+?)\]`
and `\((.+?)\)`. They match "foo" and "bar" respectively, so they are added to the array in
that order.

Tip:

If you want certain parentheses to be not captured as a group, add `?:` after the opening
parenthesis, like `(?:pattern)` instead of `(pattern)`.

#### Named groups

Named groups are captured too, but their names are lost in the result.

```dart
final parser = TextParser(
  matchers: const [PatternMatcher(r'(?<year>\d{4})-(?<month>\d{2})')]
);
final elements = await parser.parse('2022-11');
print(elements.first.groups);
```

Output:

```
[2022, 11]
```

### RegExp options

How a regular expression is treated can be configured in the `TextParser` constructor.

- multiLine
- caseSensitive
- unicode
- dotAll

These options are passed to [RegExp][RegExp] internally, so refer to its
[document][RegExp_constructor] for information.

## Limitations

- This package uses regular expressions. The speed of parsing is subject to the
  performance of `RegExp` in Dart. It will take more time to parse longer text with
  multiple complex match patterns.
- On the web, parsing is always executed in the main thread because Flutter Web does
  not support [dart:isolate][isolate].

## Troubleshooting

### Why is this text not parsed as expected?

e.g. `'123abc456'` is parsed with two matchers.

- RegExp pattern in matcher 1
    - `r'\d+'`
        - Any sequence of numeric values
- RegExp pattern in matcher 2
    - `r'(?<=\d)[a-z]+'`
        - Alphabets after a number

In this example, you may expect the first match to be "123" and the next match to be "abc",
but the second match is actually "456".

This is due to the mechanism of this package that excludes already searched parts of text
in later search iterations; "123" is found in the first iteration, and then the next
iteration is targeted at "abc456", which does not match `(?<=\d)`.

An easy solution is to use `^` together with the positive lookbehind, like `(?<=\d|^)`.

**Note: Safari has no support for lookbehind assertion.** 

[TextParser]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser-class.html
[TextParser_matchers]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/matchers.html
[TextMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TextMatcher-class.html
[UrlMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlMatcher-class.html
[EmailMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/EmailMatcher-class.html
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher-class.html
[PatternMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/PatternMatcher-class.html
[parse]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/parse.html
[TextElement]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement-class.html
[TextElement_groups]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement/groups.html
[isolate]: https://api.dartlang.org/stable/dart-isolate/dart-isolate-library.html
[RegExp]: https://api.dart.dev/stable/dart-core/RegExp-class.html
[RegExp_constructor]: https://api.dart.dev/stable/dart-core/RegExp/RegExp.html