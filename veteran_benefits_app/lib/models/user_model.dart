import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String tier; // "free" or "premium"
  final DateTime createdAt;
  final List<String> savedConditions;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.tier,
    required this.createdAt,
    required this.savedConditions,
  });

  // Check if user is premium
  bool get isPremium => tier == 'premium';

  // Check if user can save more conditions
  bool canSaveCondition() {
    if (isPremium) return true;
    return savedConditions.length < 3;
  }

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      tier: data['tier'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      savedConditions: List<String>.from(data['savedConditions'] ?? []),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'tier': tier,
      'createdAt': Timestamp.fromDate(createdAt),
      'savedConditions': savedConditions,
    };
  }

  // Create a copy of UserModel with some fields updated
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? tier,
    DateTime? createdAt,
    List<String>? savedConditions,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      savedConditions: savedConditions ?? this.savedConditions,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, tier: $tier, savedConditions: ${savedConditions.length})';
  }
}
