import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  final pattern = const EmailMatcher().pattern;
  final regExp = RegExp(pattern);

  test('matches email address despite no letters around it', () async {
    const address = 'foo@example.com';
    final matches = regExp.allMatches(address);
    expect(matches.length, equals(1));
  });

  test('local part allows alphabets, numbers and _-.+', () async {
    const address = 'foo_BAR-123.a+b@example.com';
    final matches = regExp.allMatches(address);
    expect(matches.length, equals(1));
  });

  test('single letter is allowed for host and non top level domains', () async {
    const address = 'foo@1.2.aaa';
    final matches = regExp.allMatches(address);
    expect(matches.length, equals(1));
  });

  test('local part does not allow symbols other than _-.+', () async {
    const addresses = [
      'foo@bar@example.com',
      'foo!bar@example.com',
      'foo#bar@example.com',
      r'foo$bar@example.com',
      'foo%bar@example.com',
      'foo&bar@example.com',
      'foo=bar@example.com',
      'foo^bar@example.com',
      'foo~bar@example.com',
      r'foo\bar@example.com',
      'foo|bar@example.com',
      'foo*bar@example.com',
      'foo:bar@example.com',
      'foo/bar@example.com',
      'foo?bar@example.com',
    ];
    final input = addresses.join(' ');
    final matches = regExp.allMatches(input).toList();
    for (var i = 0; i < addresses.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, equals('bar@example.com'));
    }
  });

  test('matches only email address if it is enclosed with other letters',
      () async {
    const address = 'foo@example.com';
    const input = '##$address##';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(address));
  });

  test('matches email address with longer host name', () async {
    const address = 'user@mail.aaa.bbb.example.com';
    final matches = regExp.allMatches(address).toList();
    expect(matches[0].start, equals(0));
    expect(matches[0].end, equals(address.length));
  });

  test('does not match if TLD is only a single letter', () async {
    const address = 'user@example.c';
    final matches = regExp.allMatches(address);
    expect(matches.isEmpty, true);
  });

  test('does not match if TLD contains non-alphabets', () async {
    const addresses = [
      'user@example.c+m',
      'user@example.c+m',
      'user@example.c=m',
      'user@example.c=m',
    ];
    final input = addresses.join(' ');
    final matches = regExp.allMatches(input);
    expect(matches.isEmpty, true);
  });

  test('excludes non-alphabets (other than /#?) at the end of TLD', () async {
    const address = 'user@example.com';
    const addresses = ['$address+', '$address/'];
    final input = addresses.join(' ');
    final matches = regExp.allMatches(input).toList();
    for (final m in matches) {
      final found = input.substring(m.start, m.end);
      expect(found, equals(address));
    }
  });

  test('does not match if host ends with a dot', () async {
    const address = 'user@example.';
    final matches = regExp.allMatches(address);
    expect(matches.isEmpty, true);
  });

  test('no group', () async {
    const address = 'user@example.com';
    final matches = regExp.allMatches(address).toList();
    expect(matches.length, equals(1));
    expect(matches[0].groupCount, equals(0));
  });
}
