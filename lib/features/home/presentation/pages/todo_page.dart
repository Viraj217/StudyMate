import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studymate/features/auth/presentation/cubits/todo_cubit.dart';
import 'package:studymate/features/auth/presentation/cubits/todo_state.dart';
import 'package:studymate/features/auth/domain/models/todo.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  final TextEditingController _controller = TextEditingController();

  void _showEditDialog(BuildContext context, Todo todo) {
    final editController = TextEditingController(text: todo.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Todo"),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(hintText: "Update todo"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TodoCubit>().editTodoText(todo, editController.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoCubit>().deleteTodo(todo.id);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todos")),
      body: Column(
        children: [
          // Input box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: "Add a new todo..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      context.read<TodoCubit>().addTodo(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),

          // Todo list
          Expanded(
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is TodoError) {
                  return Center(child: Text("Error: ${state.message}"));
                }

                if (state is TodoLoaded) {
                  final todos = state.todos;

                  if (todos.isEmpty) {
                    return Center(child: Text("No todos yet"));
                  }

                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, i) {
                      final todo = todos[i];

                      return ListTile(
                        onLongPress: () => _showEditDialog(context, todo),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) =>
                              context.read<TodoCubit>().toggleDone(todo),
                        ),
                      );
                    },
                  );
                }

                return SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}
