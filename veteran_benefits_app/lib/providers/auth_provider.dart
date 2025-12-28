import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Auth State Changes Provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider (Firebase User)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

// User Data Provider (Firestore UserModel)
final userDataProvider = StreamProvider<UserModel?>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return Stream.value(null);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamUserDocument(currentUser.uid);
});

// Is Premium Provider
final isPremiumProvider = Provider<bool>((ref) {
  final userData = ref.watch(userDataProvider);
  return userData.maybeWhen(
    data: (user) => user?.isPremium ?? false,
    orElse: () => false,
  );
});

// Can Save Condition Provider
final canSaveConditionProvider = Provider<bool>((ref) {
  final userData = ref.watch(userDataProvider);
  return userData.maybeWhen(
    data: (user) => user?.canSaveCondition() ?? false,
    orElse: () => false,
  );
});

// Saved Conditions Provider
final savedConditionsProvider = Provider<List<String>>((ref) {
  final userData = ref.watch(userDataProvider);
  return userData.maybeWhen(
    data: (user) => user?.savedConditions ?? [],
    orElse: () => [],
  );
});

// Auth Controller Provider
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

// Auth Controller Class
class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  AuthService get _authService => _ref.read(authServiceProvider);
  FirestoreService get _firestoreService => _ref.read(firestoreServiceProvider);

  // Sign In
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Create auth account
    final userCredential = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name in auth
    await _authService.updateDisplayName(displayName);

    // Create Firestore document
    await _firestoreService.createUserDocument(
      uid: userCredential.user!.uid,
      email: email,
      displayName: displayName,
    );
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Update Display Name
  Future<void> updateDisplayName(String displayName) async {
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      await _authService.updateDisplayName(displayName);
      await _firestoreService.updateDisplayName(user.uid, displayName);
    }
  }

  // Add Saved Condition
  Future<void> addSavedCondition(String conditionId) async {
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      await _firestoreService.addSavedCondition(user.uid, conditionId);
    }
  }

  // Remove Saved Condition
  Future<void> removeSavedCondition(String conditionId) async {
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      await _firestoreService.removeSavedCondition(user.uid, conditionId);
    }
  }

  // Upgrade to Premium (placeholder)
  Future<void> upgradeToPremium() async {
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      await _firestoreService.updateUserTier(user.uid, 'premium');
    }
  }

  // Upload Profile Photo (Save Locally)
  Future<String?> uploadProfilePhoto(File imageFile) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return null;

    try {
      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create profile_photos directory if it doesn't exist
      final Directory profilePhotosDir = Directory(path.join(appDir.path, 'profile_photos'));
      if (!await profilePhotosDir.exists()) {
        await profilePhotosDir.create(recursive: true);
      }

      // Create local file path
      final String fileName = '${user.uid}.jpg';
      final String localPath = path.join(profilePhotosDir.path, fileName);

      // Copy the image file to local storage
      final File localFile = await imageFile.copy(localPath);

      // Update Firestore with the local file path
      await _firestoreService.updatePhotoUrl(user.uid, localFile.path);

      return localFile.path;
    } catch (e) {
      print('Error saving profile photo locally: $e');
      return null;
    }
  }

  // Remove Profile Photo
  Future<void> removeProfilePhoto() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    try {
      // Get the current photo URL from Firestore
      final userData = await _firestoreService.getUserDocument(user.uid);

      if (userData?.photoUrl != null) {
        // Delete local file if it exists
        final File localFile = File(userData!.photoUrl!);
        if (await localFile.exists()) {
          await localFile.delete();
        }
      }

      // Update Firestore to remove photo URL
      await _firestoreService.updatePhotoUrl(user.uid, null);
    } catch (e) {
      print('Error removing profile photo: $e');
    }
  }
}
