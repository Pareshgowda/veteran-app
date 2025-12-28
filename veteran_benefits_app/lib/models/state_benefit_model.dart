class StateBenefitModel {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final String fullDescription;
  final List<String> eligibility;
  final String value;
  final String howToApply;
  final bool residenceRequired;

  StateBenefitModel({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.fullDescription,
    required this.eligibility,
    required this.value,
    required this.howToApply,
    required this.residenceRequired,
  });

  // Factory constructor to create StateBenefitModel from JSON
  factory StateBenefitModel.fromJson(Map<String, dynamic> json) {
    return StateBenefitModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      fullDescription: json['fullDescription'] ?? '',
      eligibility: List<String>.from(json['eligibility'] ?? []),
      value: json['value'] ?? '',
      howToApply: json['howToApply'] ?? '',
      residenceRequired: json['residenceRequired'] ?? false,
    );
  }

  // Convert StateBenefitModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'eligibility': eligibility,
      'value': value,
      'howToApply': howToApply,
      'residenceRequired': residenceRequired,
    };
  }

  @override
  String toString() {
    return 'StateBenefitModel(id: $id, title: $title, category: $category)';
  }
}
