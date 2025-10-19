# Clarity - Mental Wellness (PHQ-9 & GAD-7) Flutter App

Clarity helps users self-assess mood (PHQ-9) and anxiety (GAD-7) and journal with a simple sentiment heuristic. It is for wellness and reflection only; it is NOT a medical device or diagnosis tool.

## Features
- PHQ-9 and GAD-7 questionnaires with automatic scoring
- Journal with naive sentiment score (-5..+5)
- Riverpod v3 for state management
- Material 3 theming

## Getting started
```bash
flutter pub get
flutter run
```

## Notes
- Assets located at `assets/questions/*.json` are bundled by `pubspec.yaml`.
- PHQ-9 and GAD-7 scoring follows common public thresholds.

## Disclaimer
This app does not provide medical advice. If you are in crisis or considering self-harm, contact local emergency services or a crisis hotline immediately.
