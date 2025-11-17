import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? id;
  final String title;
  final String content;
  final Timestamp createdOn;
  final List<String> hashtags;
  final bool starred;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdOn,
    this.hashtags = const [],
    required this.starred,
  });

  // fromJson - matches your Todo pattern
  factory Note.fromJson(Map<String, dynamic> json, String id) {
    return Note(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdOn: json['createdOn'] ?? Timestamp.now(),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      starred: json['starred'] ?? false,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'createdOn': createdOn,
      'hashtags': hashtags,
      'starred': starred,
    };
  }

  // copywith
  Note copywith({
    String? id,
    String? title,
    String? content,
    Timestamp? createdOn,
    List<String>? hashtags,
    bool? starred,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdOn: createdOn ?? this.createdOn,
      hashtags: hashtags ?? this.hashtags,
      starred: starred ?? this.starred,
    );
  }
}