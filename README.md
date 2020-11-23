# text_parser

A Dart package for parsing text flexibly according to preset or custom regular expression patterns.

## Usage

### Using preset matchers (URL / email address / phone number)

If `matchers` is omitted in `TextParser`, the three preset matchers (`UrlMatcher`, `EmailMatcher`
and `TelMatcher`) are used automatically.

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
after `tel:` as a phone number:

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

You can create a custom matcher easily by extending `TextMatcher`.
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

Each `TextElement` in a parse result has the property of `groups`. It is an array of strings
that have matched the smaller pattern inside each set of parentheses `( )`.

In the example above, there are two sets of parentheses in the above example: `(.+?)` in
`\[(.+?)\]` and `\((.+?)\)`. They match `foo` and `bar` respectively, so they are stored
in the array in that order.

Tip:

If `(?:pattern)` is used instead of `(pattern)`, the string that matches the pattern is
excluded from groups.

## Limitations

- Parsing is executed in the main thread on the web, although it is done in an isolate on
other platforms. `dart:isolate` does not support the web unfortunately.
- It may take seconds to parse a very long string with complicated matchers as this package
uses RegExp.
