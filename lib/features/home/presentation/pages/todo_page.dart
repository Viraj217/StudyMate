import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:studymate/features/auth/presentation/cubits/todo_cubit.dart';
import 'package:studymate/features/auth/presentation/cubits/todo_state.dart';
import 'package:studymate/features/auth/domain/models/todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String selectedFilter = 'All';
  final TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  Set<String> _allHashtags = {};

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });

    if (filter == 'All') {
      context.read<TodoCubit>().loadTodos();
    } else {
      // Filter by hashtag (remove # if present)
      String hashtag = filter.replaceFirst('#', '');
      context.read<TodoCubit>().loadTodosByHashtag(hashtag);
    }
  }

  void _showAddTodoSheet(BuildContext context) {
    final todoCubit = context.read<TodoCubit>();
    final titleController = TextEditingController();
    final hashtagController = TextEditingController();
    String priority = 'Medium';
    DateTime? deadline;
    List<String> hashtags = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Todo',
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text('Priority: '),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: priority,
                        items: ['High', 'Medium', 'Low'].map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              p,
                              style: TextStyle(
                                color: p == 'High'
                                    ? Colors.red
                                    : p == 'Medium'
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => priority = val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Deadline: '),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          deadline == null
                              ? 'Select Date'
                              : DateFormat('MMM d, y').format(deadline!),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setSheetState(() => deadline = date);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Hashtags
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hashtagController,
                          decoration: const InputDecoration(
                            hintText: 'Add hashtag (e.g. work)',
                            isDense: true,
                          ),
                          onSubmitted: (val) {
                            if (val.isNotEmpty && !hashtags.contains(val)) {
                              setSheetState(() {
                                hashtags.add(val);
                                hashtagController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final val = hashtagController.text.trim();
                          if (val.isNotEmpty && !hashtags.contains(val)) {
                            setSheetState(() {
                              hashtags.add(val);
                              hashtagController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: hashtags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setSheetState(() => hashtags.remove(tag));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          final todo = Todo(
                            id: '', // ID generated by Firestore
                            title: titleController.text.trim(),
                            isDone: false,
                            createdAt: DateTime.now(),
                            priority: priority,
                            deadline: deadline,
                            hashtags: hashtags,
                          );
                          todoCubit.addTodo(todo);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          144,
                          202,
                          238,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Add Todo',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String filter) {
    bool isSelected = filter == selectedFilter;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          _applyFilter(filter);
        },
        backgroundColor: Colors.transparent,
        selectedColor: const Color.fromARGB(255, 144, 202, 238),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey[400]!,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "Guest User";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const SizedBox(height: 30),
              _isSearching ? _buildSearchBar() : _buildHeader(name),

              const SizedBox(height: 20),

              // Title and Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Tasks',
                    style: GoogleFonts.ubuntu(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      if (kIsWeb)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.read<TodoCubit>().loadTodos();
                              },
                              icon: const Icon(
                                Icons.refresh,
                                size: 24,
                                color: Colors.black,
                              ),
                              tooltip: 'Refresh Tasks',
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _showAddTodoSheet(context),
                          icon: const Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Filter Chips
              BlocConsumer<TodoCubit, TodoState>(
                listener: (context, state) {
                  if (state is TodoLoaded && selectedFilter == 'All') {
                    setState(() {
                      _allHashtags = {};
                      for (var todo in state.todos) {
                        _allHashtags.addAll(todo.hashtags);
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is TodoLoaded || _allHashtags.isNotEmpty) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          ..._allHashtags.map(
                            (tag) => _buildFilterChip('#$tag'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 20),

              // Todo List
              Expanded(
                child: BlocBuilder<TodoCubit, TodoState>(
                  builder: (context, state) {
                    if (state is TodoLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TodoError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }

                    if (state is TodoLoaded) {
                      final todos = state.todos;

                      if (todos.isEmpty) {
                        return const Center(child: Text("No tasks found"));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: todos.length,
                        itemBuilder: (context, i) {
                          final todo = todos[i];
                          return _buildTodoItem(context, todo);
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Welcome back $name',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: const Icon(Icons.search, size: 24, color: Colors.black),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            size: 24,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        context.read<TodoCubit>().loadTodos();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              context.read<TodoCubit>().searchTodos(value);
              setState(() {});
            },
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              searchController.clear();
            });
            context.read<TodoCubit>().loadTodos();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildTodoItem(BuildContext context, Todo todo) {
    Color priorityColor;
    switch (todo.priority) {
      case 'High':
        priorityColor = Colors.red.shade100;
        break;
      case 'Low':
        priorityColor = Colors.green.shade100;
        break;
      default:
        priorityColor = Colors.orange.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isDone,
          activeColor: const Color.fromARGB(255, 144, 202, 238),
          onChanged: (_) => context.read<TodoCubit>().toggleDone(todo),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    todo.priority,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (todo.deadline != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d').format(todo.deadline!),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            if (todo.hashtags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: todo.hashtags.map((tag) {
                  return Text(
                    '#$tag',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 122, 204),
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => context.read<TodoCubit>().deleteTodo(todo.id),
        ),
      ),
    );
  }
}
