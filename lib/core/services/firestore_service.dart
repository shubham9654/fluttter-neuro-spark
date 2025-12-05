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
    await _gameStatsCollection.doc('current').set(stats, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> watchGameStats() {
    return _gameStatsCollection.doc('current').snapshots();
  }
}

