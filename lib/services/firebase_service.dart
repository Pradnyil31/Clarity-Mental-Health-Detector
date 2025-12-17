import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Get Firestore instance
      _firestore = FirebaseFirestore.instance;

      // Get Auth instance
      _auth = FirebaseAuth.instance;

      // Configure Firestore settings for offline persistence
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Firebase initialized successfully
    } catch (e) {
      // Error initializing Firebase
      rethrow;
    }
  }

  static bool get isInitialized => _firestore != null && _auth != null;
}
