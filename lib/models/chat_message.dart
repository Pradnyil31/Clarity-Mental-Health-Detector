class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? emotionLabel;
  final double? emotionScore;
  final String sessionId;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.emotionLabel,
    this.emotionScore,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'emotionLabel': emotionLabel,
      'emotionScore': emotionScore,
      'sessionId': sessionId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      emotionLabel: json['emotionLabel'] as String?,
      emotionScore: (json['emotionScore'] as num?)?.toDouble(),
      sessionId: json['sessionId'] as String,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? emotionLabel,
    double? emotionScore,
    String? sessionId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      emotionLabel: emotionLabel ?? this.emotionLabel,
      emotionScore: emotionScore ?? this.emotionScore,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
