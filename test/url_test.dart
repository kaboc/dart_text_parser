import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  final pattern = const UrlMatcher().pattern;
  final regExp = RegExp(pattern);

  test('matches URL even despite no letters around it', () async {
    const url = 'https://example.com/';
    final matches = regExp.allMatches(url);
    expect(matches.length, equals(1));
  });

  test('supports both http and https', () async {
    final matches = regExp.allMatches(
      'http://example.com/ https://example.com/',
    );
    expect(matches.length, equals(2));
  });

  test('result does not contain strings before URL', () async {
    const url = 'https://example.com/';
    const input = '123$url';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('dot at the end is excluded', () async {
    const url = 'https://example.com/';
    const input1 = '$url.';
    final matches1 = regExp.allMatches(input1).toList();
    final found1 = input1.substring(matches1[0].start, matches1[0].end);
    expect(found1, equals(url));

    const input2 = '$url.\n';
    final matches2 = regExp.allMatches(input2).toList();
    final found2 = input2.substring(matches2[0].start, matches2[0].end);
    expect(found2, equals(url));
  });

  test('path containing a dot is not excluded', () async {
    const url = 'https://example.com/foo.jpg';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('matches URL without http:// or https://', () async {
    const url = 'example.com';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('matches URL starting with //', () async {
    const url = '//example.com';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('scheme is excluded if it is misspelled', () async {
    const url = '//example.com';
    const input = 'ttps:$url';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('matches URL with localhost or an IP address', () async {
    const urls = [
      'http://localhost/',
      'https://127.0.0.1/',
      '192.168.0.1',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, equals(urls[i]));
    }
  });

  test('matches commonly used formats', () async {
    const urls = [
      'https://example.com:8080/',
      'https://example.com?a=1',
      'https://example.com/?a=1',
      'https://example.com#abc',
      'https://example.com/#abc',
      'https://example.com/#abc?a=1',
      'https://example.com/#abc?a=1&b=%E3%83%86%E3%82%B9%E3%83%88',
      'https://www.example.com/',
      'https://aaa-bbb.example.com/~ccc/ddd/eee',
      'https://1.2.aaa:10/',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, equals(urls[i]));
    }
  });

  test('does not match if TLD is only a single letter', () async {
    const url1 = 'https://example.c';
    const url2 = 'https://example.c:8080';
    const input = '$url1 $url2';
    final matches = regExp.allMatches(input);
    expect(matches.isEmpty, true);
  });

  test('does not match if TLD contains non-alphabets', () async {
    const urls = [
      'https://example.c+m',
      'https://example.c+m/',
      'https://example.c=m',
      'https://example.c=m',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input);
    expect(matches.isEmpty, true);
  });

  test('excludes non-alphabets (other than /#?) at the end of TLD', () async {
    const url = 'https://example.com';
    const urls = ['$url+', '$url=', '$url%'];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, equals(url));
  });

  test('does not match if host ends with a dot', () async {
    const url1 = 'https://example.';
    const url2 = 'https://example.:8080';
    const input = '$url1 $url2';
    final matches = regExp.allMatches(input);
    expect(matches.isEmpty, true);
  });

  test('no group', () async {
    const url = 'https://example.com/';
    final matches = regExp.allMatches(url).toList();
    expect(matches.length, equals(1));
    expect(matches[0].groupCount, equals(0));
  });
}
