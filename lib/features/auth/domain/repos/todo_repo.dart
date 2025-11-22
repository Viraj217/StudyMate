import 'package:studymate/features/auth/domain/models/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> getTodos();
  Stream<List<Todo>> getTodosByHashtag(String hashtag);
  Stream<List<Todo>> searchTodos(String query);
  Future<void> addTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
