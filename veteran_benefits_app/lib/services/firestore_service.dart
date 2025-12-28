import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      final userDoc = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        tier: 'free',
        createdAt: DateTime.now(),
        savedConditions: [],
      );

      await _usersCollection.doc(uid).set(userDoc.toFirestore());
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  // Get user document
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data: $e';
    }
  }

  // Stream user document
  Stream<UserModel?> streamUserDocument(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update display name
  Future<void> updateDisplayName(String uid, String displayName) async {
    try {
      await _usersCollection.doc(uid).update({
        'displayName': displayName,
      });
    } catch (e) {
      throw 'Failed to update display name: $e';
    }
  }

  // Add saved condition
  Future<void> addSavedCondition(String uid, String conditionId) async {
    try {
      await _usersCollection.doc(uid).update({
        'savedConditions': FieldValue.arrayUnion([conditionId]),
      });
    } catch (e) {
      throw 'Failed to save condition: $e';
    }
  }

  // Remove saved condition
  Future<void> removeSavedCondition(String uid, String conditionId) async {
    try {
      await _usersCollection.doc(uid).update({
        'savedConditions': FieldValue.arrayRemove([conditionId]),
      });
    } catch (e) {
      throw 'Failed to remove condition: $e';
    }
  }

  // Update user tier
  Future<void> updateUserTier(String uid, String tier) async {
    try {
      await _usersCollection.doc(uid).update({
        'tier': tier,
      });
    } catch (e) {
      throw 'Failed to update tier: $e';
    }
  }

  // Update photo URL
  Future<void> updatePhotoUrl(String uid, String? photoUrl) async {
    try {
      await _usersCollection.doc(uid).update({
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw 'Failed to update photo URL: $e';
    }
  }

  // Check if condition is saved
  Future<bool> isConditionSaved(String uid, String conditionId) async {
    try {
      final user = await getUserDocument(uid);
      return user?.savedConditions.contains(conditionId) ?? false;
    } catch (e) {
      return false;
    }
  }
}
