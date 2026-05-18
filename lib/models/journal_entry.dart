// models/journal_entry.dart
// Journal entry stored via DummyJSON /posts endpoint
// Maps recipe info + mood data into the posts API fields

enum MoodTag {
  happy,
  sad,
  energy,
  comfort,
}

extension MoodTagExtension on MoodTag {
  String get label {
    switch (this) {
      case MoodTag.happy:
        return 'Happy';
      case MoodTag.sad:
        return 'Sad';
      case MoodTag.energy:
        return 'Energy';
      case MoodTag.comfort:
        return 'Comfort';
    }
  }

  String get emoji {
    switch (this) {
      case MoodTag.happy:
        return '😊';
      case MoodTag.sad:
        return '😢';
      case MoodTag.energy:
        return '⚡';
      case MoodTag.comfort:
        return '🤗';
    }
  }

  String get color {
    switch (this) {
      case MoodTag.happy:
        return '#F9C74F';
      case MoodTag.sad:
        return '#577590';
      case MoodTag.energy:
        return '#F94144';
      case MoodTag.comfort:
        return '#90BE6D';
    }
  }

  static MoodTag fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sad':
        return MoodTag.sad;
      case 'energy':
        return MoodTag.energy;
      case 'comfort':
        return MoodTag.comfort;
      default:
        return MoodTag.happy;
    }
  }
}

class JournalEntry {
  final int id;
  final String recipeName;
  final String recipeImage;
  final String cuisine;
  final MoodTag mood;
  final String note;
  final double rating;
  final int userId;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.recipeName,
    required this.recipeImage,
    required this.cuisine,
    required this.mood,
    required this.note,
    required this.rating,
    required this.userId,
    required this.createdAt,
  });

  /// Encode our data into the DummyJSON Post structure
  /// We pack our custom fields into the 'body' as a delimited string
  /// Format: "recipeName|recipeImage|cuisine|mood|rating|note"
  Map<String, dynamic> toPostJson() {
    return {
      'title': recipeName,
      'body':
          '$recipeImage|$cuisine|${mood.label}|$rating|$note',
      'userId': userId,
      'tags': [mood.label.toLowerCase()],
      'reactions': {'likes': rating.round(), 'dislikes': 0},
    };
  }

  /// Parse a DummyJSON Post back into a JournalEntry
  factory JournalEntry.fromPostJson(Map<String, dynamic> json) {
    final body = json['body'] as String? ?? '';
    final parts = body.split('|');

    String recipeImage = '';
    String cuisine = '';
    MoodTag mood = MoodTag.happy;
    double rating = 3.0;
    String note = body;

    if (parts.length >= 5) {
      recipeImage = parts[0];
      cuisine = parts[1];
      mood = MoodTagExtension.fromString(parts[2]);
      rating = double.tryParse(parts[3]) ?? 3.0;
      note = parts.sublist(4).join('|'); // Note may contain '|'
    }

    return JournalEntry(
      id: json['id'] ?? 0,
      recipeName: json['title'] ?? '',
      recipeImage: recipeImage,
      cuisine: cuisine,
      mood: mood,
      note: note,
      rating: rating,
      userId: json['userId'] ?? 1,
      createdAt: DateTime.now(),
    );
  }

  JournalEntry copyWith({
    String? recipeName,
    String? recipeImage,
    String? cuisine,
    MoodTag? mood,
    String? note,
    double? rating,
  }) {
    return JournalEntry(
      id: id,
      recipeName: recipeName ?? this.recipeName,
      recipeImage: recipeImage ?? this.recipeImage,
      cuisine: cuisine ?? this.cuisine,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
