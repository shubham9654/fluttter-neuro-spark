import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    await _tasksCollection.add(taskData);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await _tasksCollection.doc(taskId).update(updates);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Stream<QuerySnapshot> watchTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Game stats operations
  Future<void> updateGameStats(Map<String, dynamic> stats) async {
    await _gameStatsCollection.doc('current').set(stats, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> watchGameStats() {
    return _gameStatsCollection.doc('current').snapshots();
  }
}

