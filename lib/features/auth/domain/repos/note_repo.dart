import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymate/features/auth/domain/models/note.dart';

const String NOTE_COLLECTION_REF = "notes";

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _notesRef;

  NotesRepository() {
    _notesRef = _firestore
        .collection(NOTE_COLLECTION_REF)
        .withConverter<Note>(
          fromFirestore: (snapshot, _) => Note.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (note, _) => note.toJson(),
        );
  }

  // Create a new note
  Future<String> addNote(Note note) async {
    try {
      DocumentReference docRef = await _notesRef.add(note);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // Read all notes
  Stream<List<Note>> getNote() {
    return _notesRef
        .orderBy('createdOn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Note)
          .toList();
    });
  }

  // Get starred notes only
  Stream<List<Note>> getStarredNotes() {
    return _notesRef
        .where('starred', isEqualTo: true)
        .orderBy('createdOn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Note)
          .toList();
    });
  }

  // Get notes by hashtag
  Stream<List<Note>> getNotesByHashtag(String hashtag) {
    return _notesRef
        .where('hashtags', arrayContains: hashtag)
        .orderBy('createdOn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Note)
          .toList();
    });
  }

  // Update a note
  Future<void> updateNote(String id, Note note) async {
    try {
      await _notesRef.doc(id).update(note.toJson());
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await _notesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Search notes
  Stream<List<Note>> searchNotes(String query) {
    return _notesRef
        .orderBy('createdOn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Note)
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}