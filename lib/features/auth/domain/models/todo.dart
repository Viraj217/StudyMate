// import 'package:cloud_firestore/cloud_firestore.dart';

// class Todo {
//   final String id;
//   final String title;
//   final bool isDone;
//   final DateTime createdAt;

//   Todo({
//     required this.id,
//     required this.title,
//     required this.isDone,
//     required this.createdAt,
//   });

//   /// Firestore snapshot → Todo
//   factory Todo.fromDoc(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Todo(
//       id: doc.id,
//       title: data['title'] ?? '',
//       isDone: data['isDone'] ?? false,
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   /// JSON → Todo
//   factory Todo.fromJson(Map<String, dynamic> json, String id) {
//     return Todo(
//       id: id,
//       title: json['title'] ?? '',
//       isDone: json['isDone'] ?? false,
//       createdAt: (json['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Todo → JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'isDone': isDone,
//       'createdAt': createdAt,
//     };
//   }

//   Todo copyWith({
//     String? title,
//     bool? isDone,
//   }) {
//     return Todo(
//       id: id,
//       title: title ?? this.title,
//       isDone: isDone ?? this.isDone,
//       createdAt: createdAt,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  factory Todo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Todo(
      id: doc.id,
      title: data['title'] ?? "",
      isDone: data['isDone'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt,
    };
  }

  Todo copyWith({
    String? title,
    bool? isDone,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  // JSON → Todo
  factory Todo.fromJson(Map<String, dynamic> json, String id) {
    return Todo(
      id: id,
      title: json['title'] ?? '',
      isDone: json['isDone'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
