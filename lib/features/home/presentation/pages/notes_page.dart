// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:studymate/features/auth/domain/models/note.dart';
// import 'package:studymate/features/home/presentation/pages/create_note_page.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:studymate/features/auth/domain/models/todo.dart';
// import 'package:studymate/features/auth/domain/services/database_service.dart';
// // import 'package:intl/intl.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// class NotesPage extends StatefulWidget {
//   const NotesPage({super.key});

//   @override
//   _NotesPageState createState() => _NotesPageState();
// }

// class _NotesPageState extends State<NotesPage> {
//   final databaseService _databaseService = databaseService();
//   String selectedCategory = 'All';
//   List<String> categories = ['All', 'Work', 'Personal', 'Fitness'];

//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//     String name = user?.displayName ?? "Guest User";

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               SizedBox(height: 30),
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
//                       'Welcome back $name',
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
//                     icon: Icon(
//                       Icons.notifications_none,
//                       size: 24,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 20),

//               // Title and Add Button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Your Notes',
//                     style: GoogleFonts.ubuntu(
//                       fontSize: 36,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: IconButton(
//                       onPressed: () {
//                         // Navigate to add note page
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => CreateNotePage(),
//                           ),
//                         );
//                       },
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
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         DropdownButton<String>(
//                           value: selectedCategory,
//                           icon: Icon(
//                             Icons.keyboard_arrow_down,
//                             color: Colors.black,
//                           ),
//                           underline: SizedBox(),
//                           items: categories.map((String category) {
//                             return DropdownMenuItem<String>(
//                               value: category,
//                               child: Center(
//                                 child: Text(
//                                   category,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               selectedCategory = newValue!;
//                             });
//                           },
//                         ),
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
//                     bool isSelected = category == selectedCategory;
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
//                           setState(() {
//                             selectedCategory = category;
//                           });
//                         },
//                         backgroundColor: Colors.transparent,
//                         selectedColor: Color.fromARGB(255, 144, 202, 238),
//                         side: BorderSide(
//                           color: isSelected
//                               ? Colors.transparent
//                               : Colors.grey[400]!,
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

//               // Notes content area (placeholder)
//               Expanded(
//                 child: Container(
//                   // Add your notes list or grid view here
//                   child: _notesListView(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _notesListView() {
//     return Container(
//       child: StreamBuilder(
//         stream: _databaseService.getNote(),
//         builder: (context, snapshot) {
//           List notes = snapshot.data?.docs ?? [];
//           if (notes.isEmpty) {
//             return const Center(child: Text("Your notes will appear here"));
//           }
//           return ListView.builder(
//             itemCount: notes.length,
//             itemBuilder: (context, index) {
//               Note note = notes[index].data();
//               String noteID = notes[index].id;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 10,
//                 ),
//                 child: Container(
//                   child: ListTile(
//                     title: Text(note.title),

//                     subtitle: Text(
//                       DateFormat(
//                         "dd-MM-yyyy h:mm a",
//                       ).format(note.createdOn.toDate()),
//                     ),
//                     trailing: IconButton(
//                       onPressed: () {
//                         Note updatedTodo = note.copywith(
//                           starred: !note.starred,
//                         );
//                         _databaseService.updateNote(noteID, updatedTodo);
//                       },
//                       icon: Icon(
//                         note.starred ? Icons.star : Icons.star_border,
//                         color: note.starred ? Colors.amber : Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/auth/presentation/cubits/note_cubits.dart';
import 'package:studymate/features/auth/presentation/cubits/note_states.dart';
import 'package:studymate/features/home/presentation/pages/create_note_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String selectedFilter = 'All';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().loadNotes();
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });

    if (filter == 'All') {
      context.read<NotesCubit>().loadNotes();
    } else if (filter == 'Starred') {
      context.read<NotesCubit>().loadStarredNotes();
    } else {
      // Filter by hashtag (remove # if present)
      String hashtag = filter.replaceFirst('#', '');
      context.read<NotesCubit>().loadNotesByHashtag(hashtag);
    }
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
                    onPressed: () {
                      _showSearchDialog(context);
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
              ),

              const SizedBox(height: 20),

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateNotePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 24, color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Filter Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      underline: const SizedBox(),
                      items: ['All', 'Starred'].map((String filter) {
                        return DropdownMenuItem<String>(
                          value: filter,
                          child: Text(
                            filter,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _applyFilter(newValue);
                        }
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.grid_view, color: Colors.black, size: 20),
                      const SizedBox(width: 12),
                      Icon(Icons.menu, color: Colors.grey[400], size: 20),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Dynamic Hashtag Filters
              BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoaded) {
                    // Extract unique hashtags from all notes
                    Set<String> allHashtags = {};
                    for (var note in state.notes) {
                      allHashtags.addAll(note.hashtags);
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          _buildFilterChip('Starred'),
                          ...allHashtags.map((tag) => _buildFilterChip('#$tag')),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 30),

              // Notes content area
              Expanded(
                child: _notesListView(),
              ),
            ],
          ),
        ),
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _notesListView() {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        if (state is NotesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotesLoaded) {
          if (state.notes.isEmpty) {
            return const Center(
              child: Text("Your notes will appear here"),
            );
          }
          return ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              Note note = state.notes[index];
              String noteID = note.id ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          note.content.length > 50
                              ? '${note.content.substring(0, 50)}...'
                              : note.content,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        if (note.hashtags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            children: note.hashtags
                                .map((tag) => Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 122, 204),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat("dd-MM-yyyy h:mm a")
                              .format(note.createdOn.toDate()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        context.read<NotesCubit>().updateNote(
                              noteID,
                              note.copywith(starred: !note.starred),
                            );
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
        } else if (state is NotesError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }
        return const Center(child: Text("Start by adding a note!"));
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search Notes'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search by title or content...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            context.read<NotesCubit>().searchNotes(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchController.clear();
              context.read<NotesCubit>().loadNotes();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}