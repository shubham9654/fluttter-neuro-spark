import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

/// Authentication service for Firebase Auth operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  
  // Initialize GoogleSignIn with clientId for web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For web, you need to provide the client ID
    // Get it from Firebase Console → Authentication → Sign-in method → Google → Web client ID
    // Or add it as a meta tag in web/index.html
    clientId: kIsWeb ? null : null, // Will use meta tag from web/index.html
  );
  
  /// Save user data to Firestore
  Future<void> _saveUserData(User user, {String? displayName}) async {
    try {
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await user.updateDisplayName(displayName);
          await user.reload();
        } catch (e) {
          debugPrint('Warning: Could not update display name: $e');
          // Continue even if display name update fails
        }
      }
      
      // Save to Firestore (non-blocking - don't fail auth if Firestore fails)
      try {
        await _firestore.createUserDocument(user);
      } catch (e) {
        debugPrint('Warning: Could not save user to Firestore: $e');
        // Don't throw - user is still authenticated even if Firestore fails
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      // Don't throw - user is still authenticated even if Firestore fails
    }
  }

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      // Save user data to Firestore
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Save user data to Firestore
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last seen in Firestore (non-blocking)
      if (userCredential.user != null) {
        // Don't await - let it run in background
        _firestore.updateUserLastSeen().catchError((e) {
          debugPrint('Background update last seen failed: $e');
        });
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      // Re-throw so the UI can handle it
      rethrow;
    }
  }

  // Create account with email and password
  Future<UserCredential?> createAccountWithEmail(
      String email, String password, {String? displayName}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user data to Firestore (non-blocking)
      if (userCredential.user != null) {
        // Don't await - let it run in background so it doesn't block navigation
        _saveUserData(userCredential.user!, displayName: displayName)
            .catchError((e) {
          debugPrint('Background save failed: $e');
        });
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error creating account: $e');
      // Re-throw so the UI can handle it
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      await currentUser?.delete();
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}

