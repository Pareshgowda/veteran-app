class ConditionModel {
  final String id;
  final String name;
  final String category;
  final String ratingRange;
  final String shortDescription;
  final String fullDescription;
  final List<String> evidenceNeeded;
  final List<String> secondaryConditions;

  ConditionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.ratingRange,
    required this.shortDescription,
    required this.fullDescription,
    required this.evidenceNeeded,
    required this.secondaryConditions,
  });

  // Factory constructor to create ConditionModel from JSON
  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      ratingRange: json['ratingRange'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      fullDescription: json['fullDescription'] ?? '',
      evidenceNeeded: List<String>.from(json['evidenceNeeded'] ?? []),
      secondaryConditions: List<String>.from(json['secondaryConditions'] ?? []),
    );
  }

  // Convert ConditionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'ratingRange': ratingRange,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'evidenceNeeded': evidenceNeeded,
      'secondaryConditions': secondaryConditions,
    };
  }

  @override
  String toString() {
    return 'ConditionModel(id: $id, name: $name, category: $category)';
  }
}
