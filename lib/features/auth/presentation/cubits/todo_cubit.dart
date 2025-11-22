import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studymate/features/auth/domain/models/todo.dart';
import 'package:studymate/features/auth/domain/repos/todo_repo.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository repo;
  StreamSubscription<List<Todo>>? _sub;

  TodoCubit(this.repo) : super(TodoInitial()) {
    loadTodos();
  }

  void loadTodos() {
    emit(TodoLoading());
    _sub?.cancel();

    _sub = repo.getTodos().listen(
      (todos) {
        emit(TodoLoaded(todos));
      },
      onError: (e) {
        emit(TodoError(e.toString()));
      },
    );
  }

  Future<void> addTodo(Todo todo) async {
    await repo.addTodo(todo);
  }

  void loadTodosByHashtag(String hashtag) {
    emit(TodoLoading());
    _sub?.cancel();

    _sub = repo
        .getTodosByHashtag(hashtag)
        .listen(
          (todos) {
            emit(TodoLoaded(todos));
          },
          onError: (e) {
            emit(TodoError(e.toString()));
          },
        );
  }

  void searchTodos(String query) {
    if (query.isEmpty) {
      loadTodos();
      return;
    }

    // emit(TodoLoading()); // Optional: avoid flickering if desired
    _sub?.cancel();

    _sub = repo
        .searchTodos(query)
        .listen(
          (todos) {
            emit(TodoLoaded(todos));
          },
          onError: (e) {
            emit(TodoError(e.toString()));
          },
        );
  }

  Future<void> toggleDone(Todo todo) async {
    await repo.updateTodo(todo.copyWith(isDone: !todo.isDone));
  }

  Future<void> deleteTodo(String id) async {
    await repo.deleteTodo(id);
  }

  Future<void> editTodoText(Todo todo, String newText) async {
    await repo.updateTodo(todo.copyWith(title: newText));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
