import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/features/home/presentation/pages/create_note_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
                  child: Center(
                    child: Text(
                      'Your notes will appear here',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:studymate/features/auth/domain/models/note.dart';
// import 'package:studymate/features/auth/domain/repos/note_repo.dart';
// import 'create_note_page.dart';

// class NotesPage extends StatelessWidget {
//   final NoteRepo notesController = Get.find<NoteRepo>();
  
//   String selectedCategory = 'Personal';
//   List<String> categories = ['All', 'work', 'Personal', 'Fitness'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
              
//               // Header
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.grey[300],
//                     child: Icon(Icons.person, color: Colors.grey[600]),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Welcome back Chad',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.search, size: 24, color: Colors.black),
//                   ),
//                   IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.notifications_none, size: 24, color: Colors.black),
//                   ),
//                 ],
//               ),
              
//               SizedBox(height: 40),
              
//               // Title and Add Button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Your Notes',
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: IconButton(
//                       onPressed: _addNote,
//                       icon: Icon(Icons.add, size: 24, color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
              
//               SizedBox(height: 30),
              
//               // Dropdown and View Toggle
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           selectedCategory,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black,
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Icon(Icons.keyboard_arrow_down, color: Colors.black),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Icon(Icons.grid_view, color: Colors.black, size: 20),
//                       SizedBox(width: 12),
//                       Icon(Icons.menu, color: Colors.grey[400], size: 20),
//                     ],
//                   ),
//                 ],
//               ),
              
//               SizedBox(height: 20),
              
//               // Filter Tags
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: categories.map((category) {
//                     bool isSelected = category == 'Personal';
//                     return Container(
//                       margin: EdgeInsets.only(right: 12),
//                       child: FilterChip(
//                         label: Text(
//                           '#$category',
//                           style: TextStyle(
//                             color: isSelected ? Colors.black : Colors.grey[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         selected: isSelected,
//                         onSelected: (bool selected) {
//                           // Handle filter selection
//                         },
//                         backgroundColor: Colors.transparent,
//                         selectedColor: Color(0xFF90EE90),
//                         side: BorderSide(
//                           color: isSelected ? Colors.transparent : Colors.grey[400]!,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         showCheckmark: false,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
              
//               SizedBox(height: 30),
              
//               // Notes List
//               Expanded(
//                 child: Obx(() {
//                   if (notesController.isLoading.value) {
//                     return Center(child: CircularProgressIndicator());
//                   }
                  
//                   if (notesController.notes.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'No notes yet. Create your first note!',
//                         style: TextStyle(
//                           color: Colors.grey[500],
//                           fontSize: 16,
//                         ),
//                       ),
//                     );
//                   }
                  
//                   return ListView.builder(
//                     itemCount: notesController.note.length,
//                     itemBuilder: (context, index) {
//                       // Note note = notesController.notes[index];
//                       return Card(
//                         margin: EdgeInsets.symmetric(vertical: 4),
//                         child: ListTile(
//                           title: Text(
//                             note.title,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(
//                             note.content,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           onTap: () {
//                             // Navigate to edit note
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Future<void> _addNote() async {
//     final result = await Get.to(() => CreateNotePage());
//     // GetX automatically updates the UI when notes list changes
//   }
// }