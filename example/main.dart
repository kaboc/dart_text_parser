import 'package:text_parser/text_parser.dart';

void main() {
  const text = '''
    abc https://example.com/sample.jpg. def
    john.doe@example.com 911 +1-012-3456-7890
    01111111111 tel:02222222222
    <a class="bar" href="https://example.com/">
      Content inside tags
    </a>
  ''';

  // Using preset matchers
  var parser = TextParser(
    matchers: const [
      EmailMatcher(),
      UrlMatcher(),
      TelMatcher(),
    ],
  );
  var elements = parser.parseSync(text);
  elements.forEach(print);

  print('-' * 20);

  // Extracting only phone number elements as an Iterable
  final telElements = elements.whereMatcherType<TelMatcher>();
  telElements.forEach(print);

  print('-' * 20);

  // Replacing matchers with new ones
  parser.matchers = const [TelMatcher(r'(?<=tel:)\d{11}')];
  elements = parser.parseSync(text);
  elements.forEach(print);

  print('-' * 20);

  // Obtaining only matching elements
  elements = parser.parseSync(text, onlyMatches: true);
  elements.forEach(print);

  print('-' * 20);

  // Multiple matchers of the same type
  parser = TextParser(
    matchers: const [
      PatternMatcher('Pattern A'),
      PatternMatcher('Pattern B'),
    ],
  );
  elements = parser.parseSync('Pattern A & Pattern B');
  elements.forEach(print);

  print('-' * 20);

  // Extracting only elements resulting from the matcher at a particular index
  final bElements = elements.whereMatcherType<PatternMatcher>(matcherIndex: 1);
  bElements.forEach(print);

  print('-' * 20);

  // Capturing unnamed and named groups
  parser = TextParser(
    matchers: const [
      PatternMatcher(r'(?<year>\d{4})-(\d{2})-(?<day>\d{2})'),
    ],
  );
  elements = parser.parseSync('2020-01-23', onlyMatches: true);
  elements.forEach(print);

  print('-' * 20);

  // Custom matcher for <a> tags
  // (`dotAll` is enabled to make '.' match line endings too)
  parser = TextParser(matchers: const [ATagMatcher()], dotAll: true);
  elements = parser.parseSync(text, onlyMatches: true);
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
