## 2.4.0

- Bump minimum Dart SDK version to 3.2.0.
- Add `parseSync()` to TextParser.
- Update tests to use `parseSync()` instead of `parse()`.
- Refactorings:
    - Rename internal `Parser` to `ParserBody`.
    - Add new `Parser` extending `ParserBody` to each of the files for web and non-web.
    - Move TextParser from the root to `src/`.

## 2.3.0

- Change `matchers` of TextParser from `List` to `Iterable`.
- Add `ExactMatcher`.

## 2.2.0

- Improve `parse()` to skip parsing if text is empty.
- Allow empty RegExp patterns.

## 2.1.1

- Fix `UrlMatcher` and `UrlLikeMatcher` to only allow a character from a very limited
  set of types at the end of a URL. ([fb56445])

## 2.1.0

- Add `matcherIndex` to `TextElement`. ([#14])
- Add `matcherIndex` argument to `whereMatcherType()` and `containsMatcherType()`. ([#14])

## 2.0.0

- **Breaking**:
    - `UrlMatcher` now matches only URLs starting with http(s). ([#10])
    - `matchers` is no longer optional. ([#12])
- Non-breaking:
    - Refactor the parser entirely. ([#8])
        - This resolves the issue that required a workaround when lookbehind assertion was used.
    - Fix `UrlMatcher` to exclude backslashes.
    - Add `UrlLikeMatcher` that matches URL-like strings not starting with http(s). ([#10])
        - This behaves the same way as `UrlMatcher` used to before this version.
    - Add assertions to check matchers and patterns are not empty.
    - Add and improve tests.

## 1.2.0-dev.2

- **Breaking**:
    - `UrlMatcher` now matches only URLs starting with http(s). ([#10])
        - This also affects the behaviour of TextParser with the default matchers.
- Non-breaking:
    - Fix `UrlMatcher` to exclude backslashes.
    - Add `UrlLikeMatcher` that matches URL-like strings not starting with http(s). ([#10])
        - This behaves the same way as `UrlMatcher` used to before this version.

## 1.2.0-dev.1

- Refactor the parser entirely. ([#8])
    - This resolves the issue that required a workaround when lookbehind assertion was used.
- Add assertions to check matchers and patterns are not empty.
- Add and improve tests.

## 1.1.0

- Add `startingOffset` argument to `reassignOffsets()`.
- Add `containsMatcherType<T>()` to `TextElementsExtension`.
- Minor refactoring.

## 1.0.1

- Downgrade meta to avoid dependency conflict with flutter_test.
- Add tests for new methods added in 1.0.0.

## 1.0.0

- Raise minimum Dart SDK version to 2.18.0.
- Remove assertion of empty match pattern from `TextMatcher`.
- Change `TextElement` to a concrete class.
- Add `copyWith()` to `TextElement`.
- Add `TextElementsExtension` with `whereMatcherType<T>()` and `reassignOffsets()` methods.

## 0.4.2

- Fix issue in default matchers where email address starting with URL-like text was parsed as URL. ([#6])
- Improve tests.

## 0.4.1

- Fix and improve `==` operator and `hashCode` of `TextElement`.
- Add tests for named groups and `PatternMatcher`.
- Describe named groups in README.
- Update lint rules and fix new warnings.

## 0.4.0

- Bump minimum Dart SDK version to 2.17.
- Update lint rules.
- Improve documentation.

## 0.3.3

- Add `PatternMatcher`.
- Fix assertion error message of `TextMatcher`.

## 0.3.2

- Simpler handling of isolate.
- Update README.
- Update dependencies.

## 0.3.1

- Fix `TextElement`'s toString() to return better string with the type name and parentheses.
- Improve README slightly.

## 0.3.0

- Add `offset` to `TextElement`.
- Refactor tests.
- Update dev dependency.

## 0.2.0

- Add `multiLine`, `caseSensitive`, `unicode` and `dotAll` to `TextParser`.
- Improve documentation and example.

## 0.1.2

- Stable null safety release.
- Simplify messaging between main thread and isolate.
- Add test to check parsing in isolate.

## 0.1.1-nullsafety.1

- Add `onlyMatches` parameter to `parse()`. 
- Fix `UrlMatcher` and `EmailMatcher`.
- Improve `UrlMatcher`.
- Minor improvements.

## 0.1.1-nullsafety.0

- Update README.

## 0.1.0-nullsafety.0

- Migrate to null safety.

## 0.0.2

- Internal changes needed for conditional import for web.
- Improve test to check groups with more than two elements.
- Improve documentation.

## 0.0.1

- Initial version.

[#6]: https://github.com/kaboc/dart_text_parser/pull/6
[#8]: https://github.com/kaboc/dart_text_parser/pull/8
[#10]: https://github.com/kaboc/dart_text_parser/pull/10
[#12]: https://github.com/kaboc/dart_text_parser/pull/12
[#14]: https://github.com/kaboc/dart_text_parser/pull/14
[fb56445]: https://github.com/kaboc/dart_text_parser/commit/fb5644553f7e271e2f7fa73747d9451a86419373