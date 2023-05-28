[![Pub Version](https://img.shields.io/pub/v/text_parser)](https://pub.dev/packages/text_parser)
[![Dart CI](https://github.com/kaboc/dart_text_parser/workflows/Dart%20CI/badge.svg)](https://github.com/kaboc/dart_text_parser/actions)
[![codecov](https://codecov.io/gh/kaboc/dart_text_parser/branch/main/graph/badge.svg?token=YTDF6ZVV3N)](https://codecov.io/gh/kaboc/dart_text_parser)

A Dart package for parsing text flexibly according to preset or custom regular expression patterns.

## Usage

### Using preset matchers (URL / email address / phone number)

The package has the following preset matchers.

- [EmailMatcher]
- [UrlMatcher]
- [UrlLikeMatcher]
- [TelMatcher]

Below is an example of using three of the preset matchers except for `UrlLikeMatcher`.

```dart
import 'package:text_parser/text_parser.dart';

Future<void> main() async {
  const text = 'abc https://example.com/sample.jpg. def\n'
      'john.doe@example.com +1-012-3456-7890';

  final parser = TextParser(
    matchers: const [
      EmailMatcher(),
      UrlMatcher(),
      TelMatcher(),
    ],
  );
  final elements = await parser.parse(text);
  elements.forEach(print);
}
```

Output:

```
TextElement(matcherType: TextMatcher, offset: 0, text: abc , groups: [])
TextElement(matcherType: UrlMatcher, offset: 4, text: https://example.com/sample.jpg, groups: [])
TextElement(matcherType: TextMatcher, offset: 34, text: . def\n, groups: [])
TextElement(matcherType: EmailMatcher, offset: 40, text: john.doe@example.com, groups: [])
TextElement(matcherType: TextMatcher, offset: 60, text:  , groups: [])
TextElement(matcherType: TelMatcher, offset: 61, text: +1-012-3456-7890, groups: [])
```

The regular expression pattern of each of them is not very strict. If it does not meet
your use case, overwrite the pattern by yourself to make it stricter, referring to the
relevant section later in this document.

#### UrlMatcher vs UrlLikeMatcher

[UrlMatcher] does not match URLs not starting with "http" (e.g. `example.com`, `//example.com`,
etc). If you want them to be matched too, use [UrlLikeMatcher] instead.

#### Extracting only matching text elements

By default, the result of [parse()][parse] contains all elements including the ones that
have [TextMatcher][TextMatcher] as `matcherType`, which are elements of a string that
did not match any match pattern. If you want to exclude them, set `onlyMatches` to `true`
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

#### Extracting text elements of a particular matcher type

```dart
final telElements = elements.whereMatcherType<TelMatcher>().toList();
```

Or use a classic way:

```dart
final telElements = elements.map((elm) => elm.matcherType == TelMatcher).toList();
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
const boldMatcher = PatternMatcher(r'\*\*(.+?)\*\*');
final parser = TextParser(matchers: [boldMatcher]);
```

#### Custom matcher class

It is also possible to create a matcher class by extending [TextMatcher][TextMatcher].

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

Named groups are captured too, but their names are lost in the resulting `groups` list.
Therefore, it does not affect the result which of unnamed or named groups are used.

Below is an example where a single match pattern contains capturing of both unnamed and
named groups. 

```dart
final parser = TextParser(
  matchers: const [PatternMatcher(r'(?<year>\d{4})-(\d{2})-(?<day>\d{2})')],
);
final elements = await parser.parse('2020-01-23');
print(elements.first);
```

Output:

```
TextElement(matcherType: PatternMatcher, offset: 0, text: 2020-01-23, groups: [2020, 01, 23])
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

[TextParser]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser-class.html
[TextParser_matchers]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/matchers.html
[TextMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TextMatcher-class.html
[UrlMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlMatcher-class.html
[UrlLikeMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlLikeMatcher-class.html
[EmailMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/EmailMatcher-class.html
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher-class.html
[PatternMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/PatternMatcher-class.html
[parse]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/parse.html
[TextElement]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement-class.html
[TextElement_groups]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement/groups.html
[isolate]: https://api.dartlang.org/stable/dart-isolate/dart-isolate-library.html
[RegExp]: https://api.dart.dev/stable/dart-core/RegExp-class.html
[RegExp_constructor]: https://api.dart.dev/stable/dart-core/RegExp/RegExp.html