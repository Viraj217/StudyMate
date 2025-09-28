import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/home/presentation/pages/create_note_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:studymate/features/auth/domain/models/todo.dart';
import 'package:studymate/features/auth/domain/services/database_service.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final databaseService _databaseService = databaseService();
  String selectedCategory = 'All';
  List<String> categories = ['All', 'Work', 'Personal', 'Fitness'];

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
              SizedBox(height: 30),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 12),
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
                    icon: Icon(Icons.search, size: 24, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_none,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Title and Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Notes',
                    style: GoogleFonts.ubuntu(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Navigate to add note page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateNotePage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.add, size: 24, color: Colors.black),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Dropdown and View Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        DropdownButton<String>(
                          value: selectedCategory,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                          underline: SizedBox(),
                          items: categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.grid_view, color: Colors.black, size: 20),
                      SizedBox(width: 12),
                      Icon(Icons.menu, color: Colors.grey[400], size: 20),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Filter Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    bool isSelected = category == selectedCategory;
                    return Container(
                      margin: EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(
                          '#$category',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.transparent,
                        selectedColor: Color.fromARGB(255, 144, 202, 238),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[400]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 30),

              // Notes content area (placeholder)
              Expanded(
                child: Container(
                  // Add your notes list or grid view here
                  child: _notesListView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notesListView() {
    return Container(
      child: StreamBuilder(
        stream: _databaseService.getNote(),
        builder: (context, snapshot) {
          List notes = snapshot.data?.docs ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text("Your notes will appear here"));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              Note note = notes[index].data();
              String noteID = notes[index].id;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Container(
                  child: ListTile(
                    title: Text(note.title),

                    subtitle: Text(
                      DateFormat(
                        "dd-MM-yyyy h:mm a",
                      ).format(note.createdOn.toDate()),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Note updatedTodo = note.copywith(
                          starred: !note.starred,
                        );
                        _databaseService.updateNote(noteID, updatedTodo);
                      },
                      icon: Icon(
                        note.starred ? Icons.star : Icons.star_border,
                        color: note.starred ? Colors.amber : Colors.grey,
                      ),
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
}
