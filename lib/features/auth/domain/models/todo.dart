import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String task;
  bool isDone;
  Timestamp createdOn;
  Timestamp deadline;

  Todo({
    required this.task,
    required this.isDone,
    required this.createdOn,
    required this.deadline,
  });

  Todo.fromJson(Map<String, Object?> json)
    : this(
        task: json['task']! as String,
        isDone: json['isDone']! as bool,
        createdOn: json['createdOn']! as Timestamp,
        deadline: json['deadline']! as Timestamp,
      );

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'isDone': isDone,
      'createdOn': createdOn,
      'deadline': deadline,
    };
  }

  Todo copywith({
    String? task,
    bool? isDone,
    Timestamp? createdOn,
    Timestamp? deadline,
  }) {
    return Todo(
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      createdOn: createdOn ?? this.createdOn,
      deadline: deadline ?? this.deadline,
    );
  }

  
}
