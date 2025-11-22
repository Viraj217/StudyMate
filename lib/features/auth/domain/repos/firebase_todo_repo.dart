import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import 'todo_repo.dart';

class FirebaseTodoRepo implements TodoRepository {
  final String uid;
  final CollectionReference<Todo> _todosRef;

  FirebaseTodoRepo(this.uid)
    : _todosRef = FirebaseFirestore.instance
          .collection('todos')
          .withConverter<Todo>(
            fromFirestore: (snap, _) =>
                Todo.fromJson(snap.data() as Map<String, dynamic>, snap.id),
            toFirestore: (todo, _) => todo.toJson(),
          );

  @override
  Stream<List<Todo>> getTodos() {
    final query = _todosRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map(
      (snap) => snap.docs.map((d) => d.data()).toList(),
    );
  }

  @override
  Stream<List<Todo>> getTodosByHashtag(String hashtag) {
    final query = _todosRef
        .where('uid', isEqualTo: uid)
        .where('hashtags', arrayContains: hashtag)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map(
      (snap) => snap.docs.map((d) => d.data()).toList(),
    );
  }

  @override
  Stream<List<Todo>> searchTodos(String query) {
    final q = _todosRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return q.snapshots().map((snap) {
      return snap.docs
          .map((d) => d.data())
          .where(
            (todo) => todo.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await FirebaseFirestore.instance.collection('todos').add({
      'title': todo.title,
      'isDone': todo.isDone,
      'createdAt': todo.createdAt,
      'uid': uid,
      'priority': todo.priority,
      'deadline': todo.deadline,
      'hashtags': todo.hashtags,
    });
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await FirebaseFirestore.instance
        .collection('todos')
        .doc(todo.id)
        .update(todo.toJson()..['uid'] = uid);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).delete();
  }

  Future<void> toggleDone(String id, bool isDone) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).update({
      'isDone': isDone,
    });
  }
}
