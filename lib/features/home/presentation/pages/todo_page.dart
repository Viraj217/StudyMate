import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/features/auth/domain/models/todo.dart';
import 'package:studymate/features/auth/domain/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final databaseService _databaseService = databaseService();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "Guest User";

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskSheet(context);
        },
        backgroundColor: Color.fromRGBO(32, 101, 210, 1),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Header Section
              Row(
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
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 24,
                      color: Colors.black,
                    ),
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
              ),

              const SizedBox(height: 20),

              Text(
                'Your Inbox',
                style: GoogleFonts.ubuntu(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(child: _messagesListView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messagesListView() {
    return Container(
      child: StreamBuilder(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          List todos = snapshot.data?.docs ?? [];
          if (todos.isEmpty) {
            return const Center(child: Text("Add a todo"));
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index].data();
              String todoID = todos[index].id;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 144, 202, 238), // blue bg
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    child: ListTile(
                      title: Text(todo.task),

                      subtitle: Text(
                        DateFormat(
                          "dd-MM-yyyy h:mm a",
                        ).format(todo.deadline.toDate()),
                      ),
                      trailing: Checkbox(
                        activeColor: Color.fromRGBO(32, 101, 210, 1),
                        checkColor: Colors.white,
                        value: todo.isDone,
                        onChanged: (value) {
                          Todo updatedTodo = todo.copywith(
                            isDone: !todo.isDone,
                          );
                          _databaseService.updateTodo(todoID, updatedTodo);
                        },
                      ),
                      onLongPress: () {
                        _databaseService.deleteTodo(todoID);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    TextEditingController taskController = TextEditingController();
    DateTime? _deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 200, 234, 255),
                          blurRadius: 5,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextField(
                        controller: taskController,
                        decoration: const InputDecoration(
                          hintText: "Enter task...",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deadline Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 200, 234, 255),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // button bg
                            foregroundColor: Colors.black, // text & icon color
                            elevation: 0, // remove elevation
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _deadline = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _deadline == null
                                ? "Pick deadline"
                                : "${_deadline!.day}-${_deadline!.month}-${_deadline!.year} "
                                      "${_deadline!.hour}:${_deadline!.minute.toString().padLeft(2, '0')}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Color.fromARGB(255, 200, 234, 255)),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (taskController.text.isEmpty ||
                              _deadline == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Fill all fields")),
                            );
                            return;
                          }

                          Todo todo = Todo(
                            task: taskController.text.trim(),
                            isDone: false,
                            createdOn: Timestamp.now(),
                            deadline: Timestamp.fromDate(_deadline!),
                          );

                          _databaseService.addTodo(todo);

                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
