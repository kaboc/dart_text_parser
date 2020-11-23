import 'package:text_parser/text_parser.dart';

Future<void> main() async {
  const text = 'abc https://example.com/sample.jpg. def\n'
      'foo@example.com 911 +1-012-3456-7890\n'
      '01111111111 tel:02222222222'
      'abcde[foo](bar)fghij';

  final parser = TextParser();
  var elements = await parser.parse(text);
  elements.forEach(print);

  print('-' * 20);

  parser.matchers = const [
    TelMatcher(r'(?<=tel:)\d{11}'),
    MdLinkMatcher(),
  ];
  elements = await parser.parse(text);
  elements.forEach(print);
}

class MdLinkMatcher extends TextMatcher {
  const MdLinkMatcher() : super(r'\[(.+?)\]\((.+?)\)');
}
