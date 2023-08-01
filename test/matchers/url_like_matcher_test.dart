import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  final pattern = const UrlLikeMatcher().pattern;
  final regExp = RegExp(pattern);

  test('supports URL with http:// or https:// and also URL without them', () {
    const urls = [
      'http://example.com/',
      'https://example.com/',
      'example.com/',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(urls.length));

    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, equals(urls[i]));
    }
  });

  test('matches URL starting with //', () {
    const url = '//example.com';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('scheme is excluded if it is misspelled', () {
    const url = '//example.com';
    const input = 'ttps:$url';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('matches URL with localhost or an IP address and without scheme', () {
    const urls = [
      'localhost/',
      '192.168.0.1/',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(urls.length));

    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, equals(urls[i]));
    }
  });
}
