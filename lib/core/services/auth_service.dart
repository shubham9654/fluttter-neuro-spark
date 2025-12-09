import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../common/utils/hive_service.dart';
import '../../common/utils/constants.dart';
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
      
      // Ensure local data is scoped to this user (clear caches if user changed)
      await HiveService.switchUser(user.uid);

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

      // User cancelled the sign-in
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we have the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('Error: Missing Google authentication tokens');
        throw Exception('Failed to get Google authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Ensure local isolation immediately, then save user data (non-blocking)
      if (userCredential.user != null) {
        await HiveService.switchUser(userCredential.user!.uid);
        _saveUserData(userCredential.user!).catchError((e) {
          debugPrint('Background save user data failed: $e');
        });
      }
      
      debugPrint('✅ Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } on PlatformException catch (e) {
      // Handle ApiException: 10 (SHA-1 not configured)
      if (e.code == 'sign_in_failed' && 
          e.message != null && 
          e.message!.contains('ApiException: 10')) {
        debugPrint('❌ Google Sign-In Error: SHA-1 fingerprint not configured');
        throw Exception(
          'Google Sign-In not configured. Please add SHA-1 fingerprint to Firebase Console.\n'
          'See docs/FIX_GOOGLE_SIGNIN_ANDROID.md for instructions.'
        );
      }
      debugPrint('❌ Platform Exception during Google Sign-In: ${e.code} - ${e.message}');
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error during Google Sign-In: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error signing in with Google: $e');
      rethrow;
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
      
      // Ensure local data isolation and update last seen (non-blocking)
      if (userCredential.user != null) {
        await HiveService.switchUser(userCredential.user!.uid);
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
      
      // Save user data to Firestore (non-blocking) + ensure local isolation
      if (userCredential.user != null) {
        await HiveService.switchUser(userCredential.user!.uid);
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
      // Sign out of Firebase + Google
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      // Clear all local user-scoped data so the next user starts fresh
      await HiveService.clearUserScopedData();
      await HiveService.userBox.put(AppConstants.keyCurrentUserId, '');
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

