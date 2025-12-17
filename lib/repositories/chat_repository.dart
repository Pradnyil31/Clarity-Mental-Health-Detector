import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/firebase_service.dart';

class ChatRepository {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _collection = 'chats';

  // Add chat message
  static Future<void> addChatMessage(
    String userId,
    String sessionId,
    ChatMessage message,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      throw Exception('Failed to save chat message: $e');
    }
  }

  // Get chat messages for a session
  static Future<List<ChatMessage>> getChatMessages(
    String userId,
    String sessionId,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return query.docs.map((doc) => ChatMessage.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  // Get chat messages stream for real-time updates
  static Stream<List<ChatMessage>> getChatMessagesStream(
    String userId,
    String sessionId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get all chat sessions for a user
  static Future<List<String>> getChatSessions(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .get();

      return query.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to get chat sessions: $e');
    }
  }

  // Create new chat session
  static Future<String> createChatSession(String userId) async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .set({
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'lastMessageAt': DateTime.now().millisecondsSinceEpoch,
          });
      return sessionId;
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  // Update last message timestamp for session
  static Future<void> updateSessionLastMessage(
    String userId,
    String sessionId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .update({'lastMessageAt': DateTime.now().millisecondsSinceEpoch});
    } catch (e) {
      throw Exception('Failed to update session last message: $e');
    }
  }

  // Delete chat session
  static Future<void> deleteChatSession(String userId, String sessionId) async {
    try {
      // Delete all messages in the session first
      final messagesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .collection('messages')
          .get();

      for (final doc in messagesQuery.docs) {
        await doc.reference.delete();
      }

      // Delete the session document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat session: $e');
    }
  }

  // Get chat messages by date range
  static Future<List<ChatMessage>> getChatMessagesByDateRange(
    String userId,
    String sessionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(sessionId)
          .collection('messages')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'timestamp',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('timestamp', descending: false)
          .get();

      return query.docs.map((doc) => ChatMessage.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get chat messages by date range: $e');
    }
  }
}
