import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firebase_service.dart';
import 'services/data_sync_service.dart';
import 'services/data_persistence_service.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize data sync service
  await DataSyncService.initialize();

  // Initialize data persistence service
  await DataPersistenceService.initialize();

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Initialize onboarding service
  await OnboardingService.initialize();

  runApp(const ProviderScope(child: ClarityApp()));
}
