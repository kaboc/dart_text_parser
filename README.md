[![Pub Version](https://img.shields.io/pub/v/text_parser)](https://pub.dev/packages/text_parser)
[![Dart CI](https://github.com/kaboc/dart_text_parser/workflows/Dart%20CI/badge.svg)](https://github.com/kaboc/dart_text_parser/actions)
[![codecov](https://codecov.io/gh/kaboc/dart_text_parser/branch/main/graph/badge.svg?token=YTDF6ZVV3N)](https://codecov.io/gh/kaboc/dart_text_parser)

A Dart package for parsing text flexibly according to preset or custom regular expression patterns.

## Usage

### Using the preset matchers (URL / email address / phone number)

The package has the following preset matchers.

- [EmailMatcher]
- [UrlMatcher]
- [UrlLikeMatcher]
- [TelMatcher]

Below is an example of using three of the preset matchers except for `UrlLikeMatcher`.

```dart
import 'package:text_parser/text_parser.dart';

void main() {
  const text = 'abc https://example.com/sample.jpg. def\n'
      'john.doe@example.com +1-012-3456-7890';

  final parser = TextParser(
    matchers: const [
      EmailMatcher(),
      UrlMatcher(),
      TelMatcher(),
    ],
  );
  final elements = parser.parseSync(text);
  elements.forEach(print);
}
```

Output:

```
TextElement(matcherType: TextMatcher, matcherIndex null, offset: 0, text: abc , groups: [])
TextElement(matcherType: UrlMatcher, matcherIndex 1, offset: 4, text: https://example.com/sample.jpg, groups: [])
TextElement(matcherType: TextMatcher, matcherIndex null, offset: 34, text: . def\n, groups: [])
TextElement(matcherType: EmailMatcher, matcherIndex 0, offset: 40, text: john.doe@example.com, groups: [])
TextElement(matcherType: TextMatcher, matcherIndex null, offset: 60, text:  , groups: [])
TextElement(matcherType: TelMatcher, matcherIndex 2, offset: 61, text: +1-012-3456-7890, groups: [])
```

The regular expression pattern of each of them is not very strict. If it does not meet
your use case, overwrite the pattern by yourself to make it stricter, referring to the
relevant section later in this document.

#### parse() vs parseSync()

[parseSync()][parseSync] literally executes parsing synchronously. If you want
to prevent an execution from blocking the UI in Flutter or pauses other tasks
in pure Dart, use [parse()][parse] instead.

- `useIsolate: false`
    - Parsing is scheduled as a microtask.
- `useIsolate: true` (default)
    - Parsing is executed in an [isolate][isolate].
    - On Flutter Web, this is treated the same as `useIsolate: false` since
      dart:isolate is not supported on the platform.

#### UrlMatcher vs UrlLikeMatcher

[UrlMatcher] does not match URLs not starting with "http" (e.g. `example.com`, `//example.com`,
etc). If you want them to be matched too, use [UrlLikeMatcher] instead.

#### matcherType and matcherIndex

`matcherType` contained in a [TextElement] object is the type of the matcher used
to parse the text into the element. `matcherIndex` is the index of the matcher in
the matcher list passed to the `matchers` argument of [TextParser].

#### Extracting only matching text elements

By default, the result of [parse()][parse] or [parseSync()][parseSync] contains
all elements including the ones that have [TextMatcher][TextMatcher] as `matcherType`,
which are elements of a string that did not match any match pattern. If you want
to exclude them, pass `onlyMatches: true` when calling `parse()` or `parseSync()`.

```dart
final elements = parser.parseSync(text, onlyMatches: true);
elements.forEach(print);
```

Output:

```
TextElement(matcherType: UrlMatcher, matcherIndex 1, offset: 4, text: https://example.com/sample.jpg, groups: [])
TextElement(matcherType: EmailMatcher, matcherIndex 0, offset: 40, text: foo@example.com, groups: [])
TextElement(matcherType: TelMatcher, matcherIndex 2, offset: 56, text: +1-012-3456-7890, groups: [])
```

#### Extracting text elements of a particular matcher type

```dart
final telElements = elements.whereMatcherType<TelMatcher>().toList();
```

Or use a classic way:

```dart
final telElements = elements.map((elm) => elm.matcherType == TelMatcher).toList();
```

#### Conflict between matchers

If multiple matchers have matched the string at the same position in text, the first one
in those matchers takes precedence.

```dart
final parser = TextParser(matchers: const[UrlLikeMatcher(), EmailMatcher()]);
final elements = parser.parseSync('foo.bar@example.com');
```

In this example, `UrlLikeMatcher` matches `foo.bar` and `EmailMatcher` matches
`foo.bar@example.com`, but `UrlLikeMatcher` is used because it is written before
`EmailMatcher` in the matchers list.

### Overwriting the pattern of an existing matcher

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
final elements = parser.parseSync(text, onlyMatches: true);
print(elements.first.groups);
```

Output:

```
[https://example.com/, Content inside tags]
```

### ExactMatcher

`ExactMatcher` escapes reserved characters of RegExp so that those are used
as ordinary characters. The parser extracts the substrings that exactly match
any of the strings in the passed list.

```dart
TextParser(
  matchers: [
    // 'e.g.' matches only 'e.g.', not 'edge' nor 'eggs'.
    ExactMatcher(['e.g.', 'i.e.']),
  ],
)
```

### Groups

Each [TextElement][TextElement] in a parse result has the property of
[groups][TextElement_groups]. It is a list of strings that have matched the smaller pattern
inside every set of parentheses `( )`.

Below is an example of a pattern that matches a Markdown style link.

```dart
r'\[(.+?)\]\((.*?)\)'
```

This pattern has two sets of parentheses; `(.+?)` in `\[(.+?)\]` and `(/*?)` in `\((.*?)\)`.
When this matches `[foo](bar)`, the first set of parentheses captures "foo" and the second
set captures "bar", so `groups` results in `['foo', 'bar']`.

Tip:

If you want certain parentheses to be not captured as a group, add `?:` after the opening
parenthesis, like `(?:pattern)` instead of `(pattern)`.

#### Named groups

Named groups are captured too, but their names are lost in the resulting `groups` list.
Below is an example where a single match pattern contains capturing of both unnamed and
named groups. 

```dart
final parser = TextParser(
  matchers: const [PatternMatcher(r'(?<year>\d{4})-(\d{2})-(?<day>\d{2})')],
);
final elements = parser.parseSync('2020-01-23');
print(elements.first);
```

Output:

```
TextElement(matcherType: PatternMatcher, matcherIndex 0, offset: 0, text: 2020-01-23, groups: [2020, 01, 23])
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
[ExactMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/ExactMatcher-class.html
[PatternMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/PatternMatcher-class.html
[parse]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/parse.html
[parseSync]: https://pub.dev/documentation/text_parser/latest/text_parser/TextParser/parseSync.html
[TextElement]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement-class.html
[TextElement_groups]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement/groups.html
[isolate]: https://api.dartlang.org/stable/dart-isolate/dart-isolate-library.html
[RegExp]: https://api.dart.dev/stable/dart-core/RegExp-class.html
[RegExp_constructor]: https://api.dart.dev/stable/dart-core/RegExp/RegExp.html