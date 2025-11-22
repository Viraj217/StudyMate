// ignore_for_file: constant_identifier_names, camel_case_types, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/auth/domain/models/study_material.dart';
import 'package:studymate/features/auth/domain/models/todo.dart';
import 'package:studymate/features/auth/presentation/cubits/note_states.dart';

const String TODO_COLLECTION_REF = "todos";

const String NOTE_COLLECTION_REF = "notes";

const String MATERIAL_COLLECTION_REF = "materials";

class databaseService {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _todosRef;
  late final CollectionReference _notesRef;
  late final CollectionReference _materialsRef;

  databaseService() {
    _todosRef = _firestore
        .collection(TODO_COLLECTION_REF)
        .withConverter<Todo>(
          fromFirestore: (snap, _) => Todo.fromJson(snap.data()!, snap.id),
          toFirestore: (todo, _) => todo.toJson(),
        );

    _notesRef = _firestore
        .collection(NOTE_COLLECTION_REF)
        .withConverter<Note>(
          fromFirestore: (snapshots, _) =>
              Note.fromJson(snapshots.data()!, snapshots.id),
          toFirestore: (note, _) => note.toJson(),
        );

    _materialsRef = _firestore
        .collection(MATERIAL_COLLECTION_REF)
        .withConverter<StudyMaterial>(
          fromFirestore: (snap, _) =>
              StudyMaterial.fromJson(snap.data()!, snap.id),
          toFirestore: (material, _) => material.toJson(),
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

  void addNote(Note note) async {
    await _notesRef.add(note.toJson());
  }

  void updateNote(String noteID, Note note) {
    _notesRef.doc(noteID).update(note.toJson());
  }

  Future<void> addMaterial(StudyMaterial material) async {
    await _materialsRef.add(material);
  }

  Stream<QuerySnapshot> getMaterials(String uid) {
    return _materialsRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
