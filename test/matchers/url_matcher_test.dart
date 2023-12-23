import 'package:test/test.dart';

import 'package:text_parser/text_parser.dart';

void main() {
  final pattern = const UrlMatcher().pattern;
  final regExp = RegExp(pattern);

  test('matches URL when there are no letters around it', () {
    const url = 'https://example.com/';
    final matches = regExp.allMatches(url).toList();
    expect(matches, hasLength(1));

    final found = url.substring(matches[0].start, matches[0].end);
    expect(found, url);
  });

  test('result does not contain strings before URL', () {
    const url = 'https://example.com/';
    const input = 'abc$url';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, url);
  });

  test('supports both http and https', () {
    const urls = [
      'http://example.com/',
      'https://example.com/',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(urls.length));

    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, urls[i]);
    }
  });

  test('does not match if TLD is only a single letter', () {
    const url1 = 'https://example.c';
    const url2 = 'https://example.c:8080';
    const input = '$url1 $url2';
    final matches = regExp.allMatches(input);
    expect(matches, isEmpty);
  });

  test('does not match if TLD contains non-alphabets', () {
    const urls = [
      'https://example.c+m',
      'https://example.c+m/',
      'https://example.c=m',
      'https://example.c=m',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input);
    expect(matches, isEmpty);
  });

  test('excludes non-alphabets (other than /#?) at the end of TLD', () {
    const url = 'https://example.com';
    const urls = ['$url+', '$url=', '$url%'];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, url);
  });

  test('does not match if host ends with a dot', () {
    const url1 = 'https://example.';
    const url2 = 'https://example.:8080';
    const input = '$url1 $url2';
    final matches = regExp.allMatches(input);
    expect(matches, isEmpty);
  });

  test('only very limited characters are allowed at the end of path', () {
    const urls1 = {
      'https://example.com/111',
      'https://example.com/aaa',
      'https://example.com/AAA',
      r'https://example.com/111_',
      r'https://example.com/111-',
      'https://example.com/111~',
    };

    for (final input in urls1) {
      final match = regExp.firstMatch(input)!;
      final found = input.substring(match.start, match.end);
      expect(found, input);
    }

    const urls2 = {
      'https://example.com/aaa ',
      r'https://example.com/aaa.',
      r'https://example.com/aaa\',
      'https://example.com/aaa!',
      'https://example.com/aaa#',
      r'https://example.com/aaa$',
      'https://example.com/aaa&',
      "https://example.com/aaa'",
      'https://example.com/aaa(',
      'https://example.com/aaa)',
      'https://example.com/aaa*',
      'https://example.com/aaa+',
      'https://example.com/aaa,',
      'https://example.com/aaa:',
      'https://example.com/aaa;',
      'https://example.com/aaa=',
      'https://example.com/aaa?',
      'https://example.com/aaa@',
      'https://example.com/aaa[',
      'https://example.com/aaa]',
      'https://example.com/aaa）',
      'https://example.com/aaaあ',
    };

    for (final input in urls2) {
      final match = regExp.firstMatch(input)!;
      final found = input.substring(match.start, match.end);
      expect(found, 'https://example.com/aaa');
    }
  });

  test('path can contain dots', () {
    const url = 'https://example.com/foo.jpg';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    final found = input.substring(matches[0].start, matches[0].end);
    expect(found, url);
  });

  test('backslashes are not considered part of URL', () {
    const url = r'https://example.com/foo\\bar.jpg\\';
    final matches = regExp.allMatches(url).toList();
    expect(matches, hasLength(1));
    final found = url.substring(matches[0].start, matches[0].end);
    expect(found, 'https://example.com/foo');
  });

  test('does not match URL without http:// or https://', () {
    const url = 'example.com';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    expect(matches, isEmpty);
  });

  test('does not match URL starting with //', () {
    const url = '//example.com';
    const input = '111 $url 222';
    final matches = regExp.allMatches(input).toList();
    expect(matches, isEmpty);
  });

  test('scheme is excluded if it is misspelled', () {
    const url = 'ttps://example.com';
    final matches = regExp.allMatches(url).toList();
    expect(matches, isEmpty);
  });

  test('matches URL with localhost or an IP address', () {
    const urls = [
      'http://localhost/',
      'https://127.0.0.1/',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(urls.length));

    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, urls[i]);
    }
  });

  test('matches commonly used formats', () {
    const urls = [
      'http://example.com:8080/',
      'https://example.com?a=1',
      'https://example.com:10000/?a=1',
      'http://example.com#abc',
      'https://example.com/#abc',
      'https://example.com/#abc?a=1',
      'https://example.com/#abc?a=1&b=%E3%83%86%E3%82%B9%E3%83%88',
      'https://example.com/aaa',
      'https://example.com/aaa?a=1',
      'https://example.com/aaa?#abc',
      'https://example.com/aaa?#abc?a=1',
      'https://example.com/aaa/',
      'https://example.com/aaa/?a=1',
      'https://example.com/aaa/#abc',
      'https://example.com/aaa/#abc?a=1',
      'https://www.example.com/',
      'http://aaa-bbb.example.com/~ccc/ddd/eee',
      'https://1.2.aaa:10/',
    ];
    final input = urls.join(' ');
    final matches = regExp.allMatches(input).toList();
    expect(matches, hasLength(urls.length));

    for (var i = 0; i < urls.length; i++) {
      final found = input.substring(matches[i].start, matches[i].end);
      expect(found, urls[i]);
    }
  });

  test('result has no group', () {
    const url = 'https://example.com/aaa/bbb';
    final matches = regExp.allMatches(url).toList();
    expect(matches, hasLength(1));
    expect(matches[0].groupCount, 0);
  });
}
