import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/auth/domain/repos/note_repo.dart';
import 'package:studymate/features/auth/presentation/cubits/note_states.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _repository;
  StreamSubscription<List<Note>>? _notesSubscription;

  NotesCubit(this._repository) : super(NotesInitial());

  // Load all notes
  void loadNotes() {
    emit(NotesLoading());
    _notesSubscription?.cancel();
    _notesSubscription = _repository.getNote().listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError(error.toString()));
      },
    );
  }

  // Load starred notes only
  void loadStarredNotes() {
    emit(NotesLoading());
    _notesSubscription?.cancel();
    _notesSubscription = _repository.getStarredNotes().listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError(error.toString()));
      },
    );
  }

  // Load notes by hashtag
  void loadNotesByHashtag(String hashtag) {
    emit(NotesLoading());
    _notesSubscription?.cancel();
    _notesSubscription = _repository.getNotesByHashtag(hashtag).listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError(error.toString()));
      },
    );
  }

  // Create a new note
  Future<void> createNote(Note note) async {
    try {
      await _repository.addNote(note);
      emit(const NoteOperationSuccess('Note created successfully'));
      loadNotes(); // Reload notes after creation
    } catch (e) {
      emit(NotesError('Failed to create note: ${e.toString()}'));
    }
  }

  // Update an existing note
  Future<void> updateNote(String id, Note note) async {
    try {
      await _repository.updateNote(id, note);
      emit(const NoteOperationSuccess('Note updated successfully'));
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      emit(const NoteOperationSuccess('Note deleted successfully'));
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }

  // Search notes
  void searchNotes(String query) {
    if (query.isEmpty) {
      loadNotes();
      return;
    }
    
    emit(NotesLoading());
    _notesSubscription?.cancel();
    _notesSubscription = _repository.searchNotes(query).listen(
      (notes) {
        emit(NotesLoaded(notes));
      },
      onError: (error) {
        emit(NotesError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}