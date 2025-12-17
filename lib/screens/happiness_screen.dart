import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import 'assessment_screen.dart';

class HappinessScreen extends ConsumerWidget {
  const HappinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AssessmentScreen(kind: AssessmentKind.happiness);
  }
}
