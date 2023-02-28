## 1.0.1

- Downgrade meta to avoid dependency conflict with flutter_test.
- Add tests for new methods added in 1.0.0.

## 1.0.0

- Raise minimum Dart SDK version to 2.18.0.
- Remove assertion of empty match pattern from `TextMatcher`.
- Change `TextElement` to a concrete class.
- Add `copyWith()` to `TextElement`.
- Add `TextElementsExtension` with `whereMatcher<T>()` and `reassignOffsets()` methods.

## 0.4.2

- Fix issue in default matchers where email address starting with URL-like text was parsed as URL. (#6)
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
