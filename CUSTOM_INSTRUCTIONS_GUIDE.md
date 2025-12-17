# 🎯 Custom Instructions & App Integration Guide

## 🚀 New Feature: Contextual App Suggestions

I've enhanced your chat system to provide **contextual suggestions** that link to different functions of your app based on the detected emotion!

## 🎭 How It Works

When the AI detects an emotion, it now:
1. **Analyzes the emotion** using GoEmotions (28 emotions)
2. **Provides supportive response** with confidence level
3. **Suggests relevant app functions** with clickable buttons
4. **Links directly to helpful screens** in your app

## 📱 Suggested Actions by Emotion

### 😢 **Sadness, Grief, Disappointment**
- **Mood Tracker** → Log current mood
- **Journal** → Write about feelings  
- **CBT Exercises** → Cognitive behavioral techniques

### 😠 **Anger, Annoyance**
- **Breathing Exercise** → Calm down with guided breathing
- **Journal** → Express thoughts safely
- **CBT Exercises** → Manage anger with CBT

### 😰 **Fear, Nervousness**
- **Breathing Exercise** → Reduce anxiety
- **Assessment** → Check anxiety levels
- **CBT Exercises** → Anxiety management techniques

### 😊 **Joy, Excitement, Gratitude**
- **Mood Tracker** → Record positive moment
- **Journal** → Capture the feeling
- **Happiness** → Explore happiness practices

### 😳 **Embarrassment, Remorse**
- **Self-Esteem** → Build self-compassion
- **Journal** → Process feelings
- **CBT Exercises** → Challenge negative thoughts

### 🤔 **Confusion, Curiosity**
- **Insights** → Explore your patterns
- **Assessment** → Better understand yourself
- **Journal** → Explore thoughts

## 🎨 Visual Design

Each suggestion appears as a **clickable button** with:
- **Icon** representing the function
- **Title** of the app feature
- **Description** of what it does
- **Color coding** matching the emotion

## 🔧 Customization Options

### Add New App Functions
To add more app functions, update the `_getSuggestedActions` method:

```dart
case 'your_emotion':
  return [
    AppAction(
      title: 'Your Feature',
      description: 'What it does',
      icon: Icons.your_icon,
      route: '/your-route',
      color: Colors.your_color,
    ),
  ];
```

### Modify Existing Suggestions
You can customize which functions are suggested for each emotion by editing the emotion cases in `_getSuggestedActions`.

### Change Button Appearance
Modify `_buildActionButton` to change:
- Button styling
- Colors and borders
- Text formatting
- Icon sizes

## 🎯 Benefits for Users

### 1. **Contextual Help**
- No need to search for relevant features
- AI suggests exactly what might help
- Reduces cognitive load when distressed

### 2. **Seamless Navigation**
- One-tap access to helpful tools
- Maintains conversation flow
- Encourages app engagement

### 3. **Personalized Experience**
- Suggestions match emotional state
- Feels like a caring companion
- Builds trust and engagement

## 🧪 Testing the Feature

### Test Messages & Expected Suggestions

**"I'm feeling really sad today"**
- Emotion: sadness
- Suggestions: Mood Tracker, Journal, CBT Exercises

**"I'm so angry about this!"**
- Emotion: anger  
- Suggestions: Breathing Exercise, Journal, CBT Exercises

**"I'm grateful for my family"**
- Emotion: gratitude
- Suggestions: Mood Tracker, Journal, Happiness

**"I feel embarrassed about yesterday"**
- Emotion: embarrassment
- Suggestions: Self-Esteem, Journal, CBT Exercises

## 🔮 Future Enhancements

### 1. **Smart Learning**
- Track which suggestions users click
- Personalize suggestions based on usage
- A/B test different suggestion sets

### 2. **Time-Based Suggestions**
- Different suggestions for morning vs evening
- Consider user's routine and preferences
- Seasonal or weather-based suggestions

### 3. **Progress-Aware Suggestions**
- Suggest advanced features for experienced users
- Recommend next steps based on completed activities
- Celebrate milestones and achievements

### 4. **External Integrations**
- Link to external resources
- Suggest professional help when needed
- Connect with support communities

## 🎉 Result

Your chat now provides **intelligent, contextual guidance** that helps users discover and use the most relevant features of your mental health app based on their current emotional state!

Users get personalized suggestions that feel natural and helpful, making your app more engaging and therapeutically effective.