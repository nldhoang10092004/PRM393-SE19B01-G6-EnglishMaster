import '../../../../core/utils/json_utils.dart';

/// A saved flashcard with its current review statistics.
class SavedWord {
  const SavedWord({
    required this.itemId,
    required this.front,
    required this.back,
    this.example = '',
    this.isMastered = false,
    this.reviewCount = 0,
    this.lastReviewedAt,
  });
  final int itemId;
  final String front;
  final String back;
  final String example;
  final bool isMastered;
  final int reviewCount;
  final DateTime? lastReviewedAt;

  factory SavedWord.fromJson(Map<String, dynamic> json) => SavedWord(
    itemId: json.asInt('itemId'),
    front: json.asString('frontText'),
    back: json.asString('backText'),
    example: json.asString('example'),
    isMastered: json.asBool('isMastered'),
    reviewCount: json.asInt('reviewCount'),
    lastReviewedAt: json.asDate('lastReviewedAt'),
  );
}
