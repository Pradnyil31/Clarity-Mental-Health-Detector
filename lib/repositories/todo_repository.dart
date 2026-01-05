
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_item.dart';
import '../services/firebase_service.dart';

class TodoRepository {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _collection = 'todos';

  // Add todo item
  static Future<void> addTodo(String userId, TodoItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(item.id)
          .set(item.toJson());
    } catch (e) {
      throw Exception('Failed to save todo item: $e');
    }
  }

  // Update todo item
  static Future<void> updateTodo(String userId, TodoItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(item.id)
          .update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update todo item: $e');
    }
  }

  // Delete todo item
  static Future<void> deleteTodo(String userId, String todoId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(todoId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete todo item: $e');
    }
  }

  // Get all todo items for a user
  static Future<List<TodoItem>> getTodos(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => TodoItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get todo items: $e');
    }
  }

  // Get todo items stream for real-time updates
  static Stream<List<TodoItem>> getTodosStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TodoItem.fromJson(doc.data()))
              .toList(),
        );
  }
}
