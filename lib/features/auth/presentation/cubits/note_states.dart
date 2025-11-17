import 'package:studymate/features/auth/domain/models/note.dart';

abstract class NotesState {
  const NotesState();
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  const NotesLoaded(this.notes);
}

class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);
}

class NoteOperationSuccess extends NotesState {
  final String message;
  const NoteOperationSuccess(this.message);
}