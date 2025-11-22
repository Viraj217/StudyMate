import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  bool _isSearching = false;
  Set<String> _allHashtags = {};

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
              _isSearching ? _buildSearchBar() : _buildHeader(name),

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
                                context.read<NotesCubit>().loadNotes();
                              },
                              icon: const Icon(
                                Icons.refresh,
                                size: 24,
                                color: Colors.black,
                              ),
                              tooltip: 'Refresh Notes',
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            final notesCubit = context.read<NotesCubit>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: notesCubit,
                                  child: const CreateNotePage(),
                                ),
                              ),
                            );
                          },
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

              // Filter Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                      items:
                          [
                            'All',
                            'Starred',
                            ..._allHashtags.map((t) => '#$t'),
                          ].map((String filter) {
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
              // Dynamic Hashtag Filters
              BlocConsumer<NotesCubit, NotesState>(
                listener: (context, state) {
                  if (state is NotesLoaded && selectedFilter == 'All') {
                    setState(() {
                      _allHashtags = {};
                      for (var note in state.notes) {
                        _allHashtags.addAll(note.hashtags);
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is NotesLoaded || _allHashtags.isNotEmpty) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          _buildFilterChip('Starred'),
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

              const SizedBox(height: 30),

              // Notes content area
              Expanded(child: _notesListView()),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            return const Center(child: Text("Your notes will appear here"));
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
                    onTap: () {
                      final notesCubit = context.read<NotesCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: notesCubit,
                            child: CreateNotePage(note: note),
                          ),
                        ),
                      );
                    },
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
                                .map(
                                  (tag) => Text(
                                    '#$tag',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 122, 204),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            "dd-MM-yyyy h:mm a",
                          ).format(note.createdOn.toDate()),
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
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text("Start by adding a note!"));
      },
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
              hintText: 'Search notes...',
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
                        context.read<NotesCubit>().loadNotes();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              context.read<NotesCubit>().searchNotes(value);
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
            context.read<NotesCubit>().loadNotes();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
