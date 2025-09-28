// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/note.dart';

// class NoteRepo {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _collection = 'notes';
  
//   Future<String> saveNote(MyNote note) async {
//     try {
//       DocumentReference docRef = await _firestore.collection(_collection).add(note.toMap());
//       return docRef.id; // Return the document ID
//     } catch (e) {
//       throw Exception('Failed to create note: $e');
//     }
//   }
  
//   Future<List<MyNote>> loadNotes() async {
//     try {
//       QuerySnapshot snapshot = await _firestore.collection(_collection).get();
//       return snapshot.docs.map((doc) {
//         return MyNote.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
//       }).toList();
//     } catch (e) {
//       throw Exception('Failed to load notes: $e');
//     }
//   }
  
//   Future<void> updateNote(MyNote note) async {
//     try {
//       if (note.id == null) throw Exception('Note ID cannot be null');
//       await _firestore.collection(_collection).doc(note.id).update(note.toMap());
//     } catch (e) {
//       throw Exception('Failed to update note: $e');
//     }
//   }
  
//   Future<void> deleteNote(String noteId) async {
//     try {
//       await _firestore.collection(_collection).doc(noteId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete note: $e');
//     }
//   }
// }  