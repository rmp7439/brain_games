import 'package:meta/meta.dart';

@immutable
class GameInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String difficulty;
  final String category;
  final bool enabled;

  const GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.category,
    required this.enabled,
  });

  GameInfo copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? difficulty,
    String? category,
    bool? enabled,
  }) {
    return GameInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameInfo &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.icon == icon &&
        other.difficulty == difficulty &&
        other.category == category &&
        other.enabled == enabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      icon,
      difficulty,
      category,
      enabled,
    );
  }
}