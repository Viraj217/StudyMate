import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:studymate/features/auth/domain/repos/note_repo.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});
  
  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  // bool _isSaving = false;
  
  
  
  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
  
  void _saveNote() {
    if (titleController.text.isNotEmpty || contentController.text.isNotEmpty) {
      Map<String, dynamic> newNote = {
        'title': titleController.text.isEmpty ? 'Untitled' : titleController.text,
        'content': contentController.text,
      };
      
      Navigator.pop(context, newNote);
    } else {
      Navigator.pop(context);
    }
  }
  
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
                  children: [
                    Text(
                      'New Note',
                      style: GoogleFonts.ubuntu(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Note Container
                    Container(
                      height: MediaQuery.of(context).size.height * 0.70, // 70% of screen height
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
                          Divider(
                            color: Colors.grey,
                            height: 1,
                          ),
                          
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
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Extra space for scrolling
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            
            // Fixed buttons container at bottom
            Container(
              padding: EdgeInsets.only(bottom: 50, left: 25, right: 25, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 15),
                  
                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveNote,
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