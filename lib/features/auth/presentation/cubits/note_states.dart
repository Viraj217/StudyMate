import 'package:studymate/features/auth/domain/models/note.dart';

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NotesLoaded extends NoteState {
  final List<Note> notes;
  NotesLoaded(this.notes);
}

class NoteError extends NoteState {
  final String message;
  NoteError(this.message);
}