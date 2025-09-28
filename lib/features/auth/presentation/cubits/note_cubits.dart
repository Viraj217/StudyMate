// // Create: features/notes/presentation/cubits/note_cubit.dart
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/models/note.dart';
// import '../../domain/repos/note_repo.dart';
// import 'note_states.dart';

// class NoteCubit extends Cubit<NoteState> {
//   final NoteRepo noteRepo;
//   List<Note> _notes = [];
  
//   NoteCubit({required this.noteRepo}) : super(NoteInitial());
  
//   List<Note> get notes => _notes;
  
//   // Load all notes
//   Future<void> loadNotes() async {
//     try {
//       emit(NoteLoading());
//       _notes = await noteRepo.loadNotes();
//       emit(NotesLoaded(_notes));
//     } catch (e) {
//       emit(NoteError(e.toString()));
//     }
//   }
  
//   // Create new note
//   Future<void> createNote(Note note) async {
//     try {
//       emit(NoteLoading());
//       await noteRepo.saveNote(note);
//       _notes.insert(0, note);
//       emit(NotesLoaded(_notes));
//     } catch (e) {
//       emit(NoteError(e.toString()));
//     }
//   }
  
//   // Update note
//   Future<void> updateNote(Note note) async {
//     try {
//       await noteRepo.updateNote(note);
//       int index = _notes.indexWhere((n) => n.id == note.id);
//       if (index != -1) {
//         _notes[index] = note;
//         emit(NotesLoaded(_notes));
//       }
//     } catch (e) {
//       emit(NoteError(e.toString()));
//     }
//   }
  
//   // Delete note
//   Future<void> deleteNote(String noteId) async {
//     try {
//       await noteRepo.deleteNote(noteId);
//       _notes.removeWhere((note) => note.id == noteId);
//       emit(NotesLoaded(_notes));
//     } catch (e) {
//       emit(NoteError(e.toString()));
//     }
//   }
// }