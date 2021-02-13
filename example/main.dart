import 'package:text_parser/text_parser.dart';

Future<void> main() async {
  const text = 'abc https://example.com/sample.jpg. def\n'
      'foo@example.com 911 +1-012-3456-7890\n'
      '01111111111 tel:02222222222'
      'abcde[foo](bar)fghij';

  // Uses preset matchers
  final parser = TextParser();
  var elements = await parser.parse(text);
  elements.forEach(print);

  print('-' * 20);

  // Extracts phone number elements from the parsed result
  final telNumbers = elements.where((elm) => elm.matcherType == TelMatcher);
  telNumbers.forEach(print);

  print('-' * 20);

  // Replaces already set matchers with new ones
  parser.matchers = const [
    TelMatcher(r'(?<=tel:)\d{11}'),
    MdLinkMatcher(),
  ];
  elements = await parser.parse(text);
  elements.forEach(print);

  print('-' * 20);

  // Obtains only matching elements
  elements = await parser.parse(text, onlyMatches: true);
  elements.forEach(print);
}

class MdLinkMatcher extends TextMatcher {
  const MdLinkMatcher() : super(r'\[(.+?)\]\((.+?)\)');
}
