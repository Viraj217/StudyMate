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
  Future<void> addTodo(String title) async {
    await FirebaseFirestore.instance.collection('todos').add({
      'title': title,
      'isDone': false,
      'createdAt': DateTime.now(),
      'uid': uid,
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
