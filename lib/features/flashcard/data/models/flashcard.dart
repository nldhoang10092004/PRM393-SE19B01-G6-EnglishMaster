import '../../../../core/utils/json_utils.dart';

/// A term and its translation in a flashcard set.
class Flashcard {
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.ipa = '',
    this.example = '',
    this.imageUrl,
  });
  final int id;
  final String front;
  final String back;
  final String ipa;
  final String example;
  final String? imageUrl;

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json.asInt('itemID'),
    front: json.asString('frontText'),
    back: json.asString('backText'),
    ipa: json.asString('ipa'),
    example: json.asString('example'),
    imageUrl: _cleanUrl(json['imageUrl']),
  );
}

/// Set metadata; items are supplied only by the detail endpoint.
class FlashcardSet {
  FlashcardSet({
    required this.id,
    required this.title,
    this.description = '',
    this.courseId,
    List<Flashcard> items = const [],
  }) : items = List.unmodifiable(items);
  final int id;
  final int? courseId;
  final String title;
  final String description;
  final List<Flashcard> items;

  factory FlashcardSet.fromJson(Map<String, dynamic> json) => FlashcardSet(
    id: json.asInt('setID'),
    courseId: json.asIntOrNull('courseID'),
    title: json.asString('title'),
    description: json.asString('description'),
    items: json.asList('items').map(Flashcard.fromJson).toList(),
  );
}

/// Server progress for one term.
class FlashcardProgress {
  const FlashcardProgress({
    required this.itemId,
    this.isMastered = false,
    this.isSaved = false,
    this.reviewCount = 0,
    this.nextReviewAt,
  });
  final int itemId;
  final bool isMastered;
  final bool isSaved;
  final int reviewCount;
  final DateTime? nextReviewAt;

  factory FlashcardProgress.fromJson(Map<String, dynamic> json) =>
      FlashcardProgress(
        itemId: json.asInt('itemId'),
        isMastered: json.asBool('isMastered'),
        isSaved: json.asBool('isSaved'),
        reviewCount: json.asInt('reviewCount'),
        nextReviewAt: json.asDate('nextReviewAt'),
      );
}

/// A recorded learning action (1 = learn, 2 = mastered).
class FlashcardHistory {
  const FlashcardHistory({
    required this.itemId,
    required this.front,
    required this.actionType,
    this.createdAt,
  });
  final int itemId;
  final String front;
  final int actionType;
  final DateTime? createdAt;

  factory FlashcardHistory.fromJson(Map<String, dynamic> json) =>
      FlashcardHistory(
        itemId: json.asInt('itemId'),
        front: json.asString('frontText'),
        actionType: json.asInt('actionType'),
        createdAt: json.asDate('createdAt'),
      );
}

String? _cleanUrl(Object? raw) {
  final value = raw is String ? raw.trim() : '';
  return value.isEmpty ? null : value;
}
