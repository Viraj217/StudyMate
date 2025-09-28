import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/auth/domain/models/todo.dart';

const String TODO_COLLECTION_REF = "todos";

const String NOTE_COLLECTION_REF = "notes";

class databaseService {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _todosRef;
  late final CollectionReference _notesRef;

  databaseService() {
    _todosRef = _firestore
        .collection(TODO_COLLECTION_REF)
        .withConverter<Todo>(
          fromFirestore: (snapshots, _) => Todo.fromJson(snapshots.data()!),
          toFirestore: (todo, _) => todo.toJson(),
        );

    _notesRef = _firestore
        .collection(NOTE_COLLECTION_REF)
        .withConverter<Note>(
          fromFirestore: (snapshots, _) => Note.fromJson(snapshots.data()!),
          toFirestore: (note, _) => note.toJson(),
        );
  }

  Stream<QuerySnapshot> getTodos() {
    return _todosRef.snapshots();
  }

  void addTodo(Todo todo) async {
    _todosRef.add(todo);
  }

  void updateTodo(String todoID, Todo todo) {
    _todosRef.doc(todoID).update(todo.toJson());
  }

  void deleteTodo(String todoID) {
    _todosRef.doc(todoID).delete();
  }

  Stream<QuerySnapshot> getNote() {
    return _notesRef.snapshots();
  }

  void addNote(Todo todo) async {
    _notesRef.add(todo);
  }
}
