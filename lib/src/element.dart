import 'package:meta/meta.dart' show immutable;

import 'matcher.dart';
import 'text_parser.dart';

/// A class that holds the information of a parsed element.
@immutable
class TextElement {
  /// Creates a [TextElement] that holds the information of a parsed element.
  const TextElement(
    this.text, {
    this.groups = const [],
    this.matcherType = TextMatcher,
    this.matcherIndex,
    this.offset = 0,
  });

  /// The string that has matched the pattern in one of the matchers
  /// specified in [TextParser], or that has not matched any pattern.
  final String text;

  /// An array of the strings that have matched each smaller pattern
  /// enclosed with parentheses in a match pattern.
  final List<String?> groups;

  /// The type of the matcher whose match pattern has matched the [text].
  /// If the type is [TextMatcher], it means no patterns have matched it.
  final Type matcherType;

  /// The index of the matcher in the matcher list passed to the
  /// `matchers` argument of [TextParser].
  ///
  /// e.g. If the matcher index is 2 in an element, it means the matcher
  /// at the third position was used to parse the [text] into the element.
  final int? matcherIndex;

  /// The offset where the [text] starts in the source text.
  final int offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextElement &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          groups.equals(other.groups) &&
          matcherType == other.matcherType &&
          matcherIndex == other.matcherIndex &&
          offset == other.offset;

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        text,
        groups,
        matcherType,
        matcherIndex,
        offset,
      ]);

  @override
  String toString() {
    final g = groups.map(_convert).join(', ');

    return 'TextElement('
        'matcherType: $matcherType, '
        'matcherIndex: $matcherIndex, '
        'offset: $offset, '
        'text: ${_convert(text)}, '
        'groups: [$g]'
        ')';
  }

  /// Creates a new [TextElement] from this one by updating individual
  /// properties.
  ///
  /// This method creates a new [TextElement] object with values for
  /// the properties provided by similarly named arguments, or using
  /// the existing value of the property if no argument, or `null`,
  /// is provided.
  TextElement copyWith({
    String? text,
    List<String?>? groups,
    Type? matcherType,
    int? matcherIndex,
    int? offset,
  }) {
    return TextElement(
      text ?? this.text,
      groups: groups ?? this.groups,
      matcherType: matcherType ?? this.matcherType,
      matcherIndex: matcherIndex ?? this.matcherIndex,
      offset: offset ?? this.offset,
    );
  }

  String? _convert(String? text) {
    return text
        ?.replaceAll('\r', r'\r')
        .replaceAll('\n', r'\n')
        .replaceAll('\t', r'\t');
  }
}

extension on List<String?> {
  bool equals(List<String?> other) {
    if (length != other.length) {
      return false;
    }

    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }

    return true;
  }
}

/// Extensions on a collection of [TextElement].
extension TextElementsExtension on Iterable<TextElement> {
  /// Returns a new lazy [Iterable] with all [TextElement]s
  /// that have type [T] as `matcherType`.
  ///
  /// Pass an index number to the [matcherIndex] argument if the source
  /// list contains elements resulting from different matchers of the
  /// same type and therefore specifying only the type is not enough.
  Iterable<TextElement> whereMatcherType<T extends TextMatcher>({
    int? matcherIndex,
  }) {
    return matcherIndex == null
        ? where((e) => e.matcherType == T)
        : where((e) => e.matcherType == T && e.matcherIndex == matcherIndex);
  }

  /// Whether the iterable contains one or more [TextElement]s
  /// that have type [T] as `matcherType`.
  ///
  /// Pass an index number to the [matcherIndex] argument if the source
  /// list contains elements resulting from different matchers of the
  /// same type and therefore specifying only the type is not enough.
  bool containsMatcherType<T extends TextMatcher>({int? matcherIndex}) {
    return matcherIndex == null
        ? any((e) => e.matcherType == T)
        : any((e) => e.matcherType == T && e.matcherIndex == matcherIndex);
  }

  /// Corrects the offsets of [TextElement]s and returns a new
  /// lazy [Iterable] with the elements.
  ///
  /// The offset of the first element is zero, or a different
  /// number if specified with [startingOffset].
  Iterable<TextElement> reassignOffsets({int startingOffset = 0}) {
    var offset = startingOffset;
    return map((elm) {
      final newElm = elm.copyWith(offset: offset);
      offset += elm.text.length;
      return newElm;
    });
  }
}
