import 'package:text_parser/text_parser.dart';

Future<void> main() async {
  const text = '''
    abc https://example.com/sample.jpg. def
    john.doe@example.com 911 +1-012-3456-7890
    01111111111 tel:02222222222
    <a class="bar" href="https://example.com/">
      Content inside tags
    </a>
  ''';

  // Uses preset matchers
  var parser = TextParser(
    matchers: const [
      EmailMatcher(),
      UrlMatcher(),
      TelMatcher(),
    ],
  );
  var elements = await parser.parse(text);
  elements.forEach(print);

  print('-' * 20);

  // Extracts only phone number elements as an Iterable
  final telElements = elements.whereMatcherType<TelMatcher>();
  telElements.forEach(print);

  print('-' * 20);

  // Replaces already set matchers with new ones
  parser.matchers = const [TelMatcher(r'(?<=tel:)\d{11}')];
  elements = await parser.parse(text);
  elements.forEach(print);

  print('-' * 20);

  // Obtains only matching elements
  elements = await parser.parse(text, onlyMatches: true);
  elements.forEach(print);

  print('-' * 20);

  // A match pattern containing capturing of unnamed and named groups
  parser = TextParser(
    matchers: const [
      PatternMatcher(r'(?<year>\d{4})-(\d{2})-(?<day>\d{2})'),
    ],
  );
  elements = await parser.parse('2020-01-23', onlyMatches: true);
  elements.forEach(print);

  print('-' * 20);

  // Uses a custom matcher for <a> tags
  // (`dotAll` is enabled to make '.' match line endings too)
  parser = TextParser(matchers: const [ATagMatcher()], dotAll: true);
  elements = await parser.parse(text, onlyMatches: true);
  elements.forEach(print);
}

class ATagMatcher extends TextMatcher {
  const ATagMatcher()
      : super(
          r'\<a\s(?:.+?\s)*?href="(.+?)".*?\>'
          r'\s*(.+?)\s*'
          r'\</a\>',
        );
}
