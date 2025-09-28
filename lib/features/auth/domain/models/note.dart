import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String title;
  bool starred;
  Timestamp createdOn;
  String content;

  Note({
    required this.title,
    required this.starred,
    required this.createdOn,
    required this.content,
  });

  Note.fromJson(Map<String, Object?> json)
    : this(
        title: json['title']! as String,
        starred: json['starred']! as bool,
        createdOn: json['createdOn']! as Timestamp,
        content: json['content']! as String,
      );

  Note copywith({
    String? title,
    bool? starred,
    Timestamp? createdOn,
    String? content,
  }) {
    return Note(
      title: title ?? this.title,
      starred: starred ?? this.starred,
      createdOn: createdOn ?? this.createdOn,
      content: content ?? this.content,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'starred': starred,
      'createdOn': createdOn,
      'content': content,
    };
  }

  // Map<String, dynamic> toMap() {
  //   return {'title': title, 'content': content};
  // }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'title': title,
  //   'content': content,
  // };

  // factory MyNote.fromFirestore(String id, Map<String, dynamic> data) {
  //   return MyNote(
  //     id: id,
  //     title: data['title'] ?? '',
  //     content: data['content'] ?? '',
  //   );
  // }

  // factory MyNote.fromJson(Map<String, dynamic> jsonUser) => MyNote(
  //   title: jsonUser['title'] as String,
  //   content: jsonUser['content'] as String,
  // );
}
