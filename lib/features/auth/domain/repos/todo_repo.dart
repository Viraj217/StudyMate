// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:studymate/features/auth/domain/models/todo.dart';

// class TodoRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<List<Todo>> getTodos() {
//     return _firestore
//         .collection('todos')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs.map((doc) => Todo.fromDoc(doc)).toList());
//   }

//   Future<void> addTodo(String title) async {
//     await _firestore.collection('todos').add({
//       'title': title,
//       'isDone': false,
//       'createdAt': DateTime.now(),
//     });
//   }

//   Future<void> updateTodo(Todo todo) async {
//     await _firestore.collection('todos').doc(todo.id).update(todo.toJson());
//   }

//   Future<void> deleteTodo(String id) async {
//     await _firestore.collection('todos').doc(id).delete();
//   }
// }

import 'package:studymate/features/auth/domain/models/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> getTodos();
  Future<void> addTodo(String title);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
