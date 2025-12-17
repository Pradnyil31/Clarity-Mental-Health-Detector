import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import 'assessment_screen.dart';

class SelfEsteemScreen extends ConsumerWidget {
  const SelfEsteemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AssessmentScreen(kind: AssessmentKind.selfEsteem);
  }
}
