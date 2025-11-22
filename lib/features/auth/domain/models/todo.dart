import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final String priority;
  final DateTime? deadline;
  final List<String> hashtags;

  Todo({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.priority = 'Medium',
    this.deadline,
    this.hashtags = const [],
  });

  factory Todo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Todo(
      id: doc.id,
      title: data['title'] ?? "",
      isDone: data['isDone'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      priority: data['priority'] ?? 'Medium',
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      hashtags: List<String>.from(data['hashtags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt,
      'priority': priority,
      'deadline': deadline,
      'hashtags': hashtags,
    };
  }

  Todo copyWith({
    String? title,
    bool? isDone,
    String? priority,
    DateTime? deadline,
    List<String>? hashtags,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      hashtags: hashtags ?? this.hashtags,
    );
  }

  // JSON → Todo
  factory Todo.fromJson(Map<String, dynamic> json, String id) {
    return Todo(
      id: id,
      title: json['title'] ?? '',
      isDone: json['isDone'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      priority: json['priority'] ?? 'Medium',
      deadline: json['deadline'] != null
          ? (json['deadline'] as Timestamp).toDate()
          : null,
      hashtags: List<String>.from(json['hashtags'] ?? []),
    );
  }
}
