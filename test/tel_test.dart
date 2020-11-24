import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  final pattern = const TelMatcher().pattern;
  final regExp = RegExp(pattern);

  test('matches phone number despite no letters around it', () async {
    const input = '012-3456-7890';
    final matches = regExp.allMatches(input);
    expect(matches.length, equals(1));
  });

  test('matches 2-5 digits often used for emergency numbers', () async {
    const input = '1/11/111/1111/11111/111111';
    final matches = regExp.allMatches(input);
    expect(matches.length, equals(4));
  });

  test('matches only numerics if enclosed with non-numerics', () async {
    const number = '123';
    const input = 'abc123def';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(number));
  });

  test('country code is not caught if no space after it', () async {
    const number = '101234567890';
    const input = '+$number';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(number));
  });

  test('+0 is not regarded as part of country code', () async {
    const code = '01';

    const number1 = '01234567890';
    const input1 = '+$code-$number1';
    final matches1 = regExp.allMatches(input1).toList();
    final found1 = input1.substring(matches1[0].start, matches1[0].end);
    expect(found1, equals(code));

    const number2 = '01234567';
    const input2 = '+$code-$number2';
    final matches2 = regExp.allMatches(input2).toList();
    final found2 = input2.substring(matches2[0].start, matches2[0].end);
    expect(found2, equals('$code-$number2'));
  });

  test('matches commonly used formats', () async {
    const numbers = [
      '012-3456-7890',
      '012 3456 7890',
      '01234567890',
      '0123-4567-8900',
      '0123 4567 8900',
      '012345678900',
      '+1-012-3456-7890',
      '+1-12-3456-7890',
      '+1 012 3456 7890',
      '+1 12 3456 7890',
      '+1-1234567890',
      '+1-01234567890',
      '+1 01234567890',
      '1-012-3456-7890',
      '1-12-3456-7890',
      '1 012 3456 7890',
      '1 12 3456 7890',
      '1-01234567890',
      '1-1234567890',
      '1 01234567890',
      '+88-01-1111111',
      '+88-1-1111111',
      '+88 01 1111111',
      '+88 1 1111111',
      '+88-011111111',
      '+88-11111111',
      '+88 011111111',
      '+88 11111111',
      '88-01-1111111',
      '88-1-1111111',
      '88 01 1111111',
      '88 1 1111111',
      '88-011111111',
      '88-11111111',
      '88 011111111',
      '88 11111111',
    ];
    final input = numbers.join(' ');
    final matches = regExp.allMatches(input).toList();
    for (var i = 0; i < numbers.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, equals(numbers[i]));
    }
  });

  test('no group', () async {
    const address = '012-3456-7890';
    final matches = regExp.allMatches(address).toList();
    expect(matches.length, equals(1));
    expect(matches[0].groupCount, equals(0));
  });
}
