// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/auth/domain/services/database_service.dart';
// import 'package:studymate/features/auth/domain/repos/note_repo.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final databaseService _databaseService = databaseService();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  bool isStarred = false;
  DateTime? createdOn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New Note',
                          style: GoogleFonts.ubuntu(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: isStarred ? Colors.amber : Colors.grey,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              isStarred = !isStarred; // toggle star
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Note Container
                    Container(
                      height:
                          MediaQuery.of(context).size.height *
                          0.70, // 70% of screen height
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
                      child: Column(
                        children: [
                          // Title TextField
                          TextField(
                            controller: titleController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Divider
                          Divider(color: Colors.grey, height: 1),

                          // Content TextField
                          Expanded(
                            child: TextField(
                              controller: contentController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'Start writing your note...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (createdOn != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Created: ${createdOn!.day}/${createdOn!.month}/${createdOn!.year} ${createdOn!.hour}:${createdOn!.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // buttons container at bottom
            Container(
              padding: EdgeInsets.only(
                bottom: 50,
                left: 25,
                right: 25,
                top: 10,
              ),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),

                  SizedBox(width: 15),

                  // Save Button
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: () async {
                  //       if (titleController.text.isEmpty ||
                  //           contentController.text.isEmpty) {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text("Fill all fields")),
                  //         );
                  //         return;
                  //       }

                  //       DateTime now = DateTime.now(); // ← set creation time

                  //       Note note = Note(
                  //         title: titleController.text.trim(),
                  //         starred: isStarred,
                  //         createdOn: Timestamp.fromDate(now),
                  //         content: contentController.text.trim(),
                  //       );

                  //       // _databaseService.addNote(note);

                  //       _databaseService.addNote(note);
                  //       Navigator.pop(context);
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Color.fromARGB(255, 144, 202, 238),
                  //       padding: EdgeInsets.symmetric(vertical: 15),
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       'Save',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: Colors.black,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fill all fields")),
                          );
                          return;
                        }

                        DateTime now = DateTime.now(); // set creation time

                        Note note = Note(
                          title: titleController.text.trim(),
                          starred: isStarred,
                          createdOn: Timestamp.fromDate(now),
                          content: contentController.text.trim(),
                        );

                        try {
                          // Await the addNote Future
                          _databaseService.addNote(note);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Note saved successfully!"),
                            ),
                          );
                          Navigator.pop(context); // Go back to notes page
                        } catch (e) {
                          // Handle errors
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to save note: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 144, 202, 238),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
