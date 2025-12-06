import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firestore service for database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');
  CollectionReference get _gameStatsCollection =>
      _firestore.collection('users').doc(_userId).collection('gameStats');

  // User operations
  Future<void> createUserDocument(User user) async {
    await _usersCollection.doc(user.uid).set({
      'email': user.email ?? '',
      'displayName': user.displayName ?? 'Neurospark User',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserLastSeen() async {
    if (_userId != null) {
      await _usersCollection.doc(_userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUserDocument(Map<String, dynamic> updates) async {
    if (_userId == null) {
      debugPrint('Cannot update user document: User not authenticated');
      throw Exception('User not authenticated');
    }
    
    try {
      final userDocRef = _usersCollection.doc(_userId);
      
      // Check if document exists
      final docSnapshot = await userDocRef.get();
      
      if (!docSnapshot.exists) {
        // Document doesn't exist - create it with user data from Auth
        final user = _auth.currentUser;
        if (user != null) {
          debugPrint('📝 Creating new user document in Firestore');
          await userDocRef.set({
            'email': user.email ?? '',
            'displayName': user.displayName ?? 'Neurospark User',
            'photoURL': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeen': FieldValue.serverTimestamp(),
            ...updates, // Merge with updates
          }, SetOptions(merge: true));
        } else {
          // No user in Auth - just create with updates
          await userDocRef.set({
            'createdAt': FieldValue.serverTimestamp(),
            ...updates,
          }, SetOptions(merge: true));
        }
        debugPrint('✅ New user document created in Firestore');
      } else {
        // Document exists - update it
        debugPrint('📝 Updating existing user document in Firestore');
        await userDocRef.set(updates, SetOptions(merge: true));
        debugPrint('✅ User document updated in Firestore');
      }
      
      // Verify the update worked
      final verifySnapshot = await userDocRef.get();
      if (verifySnapshot.exists) {
        final data = verifySnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          debugPrint('✅ Verified: User document exists with fields: ${data.keys.join(", ")}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating user document in Firestore: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      debugPrint('📍 User ID: $_userId');
      rethrow;
    }
  }

  // Task operations
  Future<void> createTask(Map<String, dynamic> taskData) async {
    if (_userId == null) {
      debugPrint('Cannot create task: User not authenticated');
      return;
    }
    try {
      await _tasksCollection.add(taskData);
      debugPrint('✅ Task created in Firestore');
    } catch (e) {
      debugPrint('❌ Error creating task in Firestore: $e');
      rethrow;
    }
  }

  Future<void> createTaskWithId(String taskId, Map<String, dynamic> taskData) async {
    if (_userId == null) {
      debugPrint('Cannot create task: User not authenticated');
      return;
    }
    try {
      await _tasksCollection.doc(taskId).set(taskData, SetOptions(merge: true));
      debugPrint('✅ Task created in Firestore with ID: $taskId');
    } catch (e) {
      debugPrint('❌ Error creating task in Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    if (_userId == null) {
      debugPrint('Cannot update task: User not authenticated');
      return;
    }
    try {
      await _tasksCollection.doc(taskId).update(updates);
      debugPrint('✅ Task updated in Firestore: $taskId');
    } catch (e) {
      debugPrint('❌ Error updating task in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_userId == null) {
      debugPrint('Cannot delete task: User not authenticated');
      return;
    }
    try {
      await _tasksCollection.doc(taskId).delete();
      debugPrint('✅ Task deleted from Firestore: $taskId');
    } catch (e) {
      debugPrint('❌ Error deleting task from Firestore: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> watchTasks() {
    if (_userId == null) {
      return const Stream.empty();
    }
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get all tasks for current user
  Future<List<Map<String, dynamic>>> getTasks() async {
    if (_userId == null) {
      return [];
    }
    try {
      final snapshot = await _tasksCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting tasks from Firestore: $e');
      return [];
    }
  }

  // Game stats operations
  Future<void> updateGameStats(Map<String, dynamic> stats) async {
    if (_userId == null) {
      debugPrint('Cannot update game stats: User not authenticated');
      return;
    }
    try {
      await _gameStatsCollection.doc('current').set(stats, SetOptions(merge: true));
      debugPrint('✅ Game stats updated in Firestore');
    } catch (e) {
      debugPrint('❌ Error updating game stats in Firestore: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getGameStats() async {
    if (_userId == null) {
      return null;
    }
    try {
      final snapshot = await _gameStatsCollection.doc('current').get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting game stats from Firestore: $e');
      return null;
    }
  }

  Stream<DocumentSnapshot> watchGameStats() {
    if (_userId == null) {
      return const Stream.empty();
    }
    return _gameStatsCollection.doc('current').snapshots();
  }

  // Purchase history operations
  CollectionReference get _purchasesCollection =>
      _firestore.collection('users').doc(_userId).collection('purchases');
  
  CollectionReference get _shopPurchasesCollection =>
      _firestore.collection('users').doc(_userId).collection('shopPurchases');

  /// Save IAP purchase to history
  Future<void> savePurchaseHistory({
    required String productId,
    required String productType, // 'subscription', 'consumable', 'non_consumable'
    required String transactionId,
    required DateTime purchaseDate,
    String? price,
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) {
      debugPrint('Cannot save purchase: User not authenticated');
      return;
    }
    try {
      await _purchasesCollection.add({
        'productId': productId,
        'productType': productType,
        'transactionId': transactionId,
        'purchaseDate': Timestamp.fromDate(purchaseDate),
        'price': price,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Purchase saved to history: $productId');
    } catch (e) {
      debugPrint('❌ Error saving purchase history: $e');
      rethrow;
    }
  }

  /// Save shop purchase (coins purchase) to history
  Future<void> saveShopPurchase({
    required String itemId,
    required String itemName,
    required int coinsSpent,
    required DateTime purchaseDate,
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) {
      debugPrint('Cannot save shop purchase: User not authenticated');
      return;
    }
    try {
      await _shopPurchasesCollection.add({
        'itemId': itemId,
        'itemName': itemName,
        'coinsSpent': coinsSpent,
        'purchaseDate': Timestamp.fromDate(purchaseDate),
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Shop purchase saved to history: $itemId');
    } catch (e) {
      debugPrint('❌ Error saving shop purchase: $e');
      rethrow;
    }
  }

  /// Get all purchase history
  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    if (_userId == null) {
      return [];
    }
    try {
      final snapshot = await _purchasesCollection
          .orderBy('purchaseDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting purchase history: $e');
      return [];
    }
  }

  /// Get all shop purchase history
  Future<List<Map<String, dynamic>>> getShopPurchaseHistory() async {
    if (_userId == null) {
      return [];
    }
    try {
      final snapshot = await _shopPurchasesCollection
          .orderBy('purchaseDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting shop purchase history: $e');
      return [];
    }
  }

  /// Save user preferences to Firestore
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    if (_userId == null) {
      debugPrint('Cannot save preferences: User not authenticated');
      return;
    }
    try {
      await _usersCollection.doc(_userId).set({
        'preferences': preferences,
        'preferencesUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ User preferences saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving user preferences: $e');
      rethrow;
    }
  }

  /// Get user preferences from Firestore
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (_userId == null) {
      return null;
    }
    try {
      final doc = await _usersCollection.doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['preferences'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user preferences: $e');
      return null;
    }
  }
}

