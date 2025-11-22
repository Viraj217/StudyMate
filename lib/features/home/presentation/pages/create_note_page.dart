import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/features/auth/domain/models/note.dart';
import 'package:studymate/features/auth/presentation/cubits/note_cubits.dart';

class CreateNotePage extends StatefulWidget {
  final Note? note;
  const CreateNotePage({super.key, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  final TextEditingController hashtagController = TextEditingController();
  late bool isStarred;
  late List<String> hashtags;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
    isStarred = widget.note?.starred ?? false;
    hashtags = List.from(widget.note?.hashtags ?? []);
  }

  void _addHashtag() {
    String tag = hashtagController.text.trim();
    if (tag.isNotEmpty && !hashtags.contains(tag)) {
      setState(() {
        hashtags.add(tag);
        hashtagController.clear();
      });
    }
  }

  void _removeHashtag(String tag) {
    setState(() {
      hashtags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
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
                              isStarred = !isStarred;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Note Container
                    Container(
                      height: MediaQuery.of(context).size.height * 0.50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
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
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Divider
                          const Divider(color: Colors.grey, height: 1),

                          // Content TextField
                          Expanded(
                            child: TextField(
                              controller: contentController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                hintText: 'Start writing your note...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hashtags Section
                    Text(
                      'Hashtags',
                      style: GoogleFonts.ubuntu(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Hashtag Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hashtagController,
                            decoration: InputDecoration(
                              hintText: 'Add hashtag (e.g., flutter)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _addHashtag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addHashtag,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              144,
                              202,
                              238,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Display Hashtags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hashtags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeHashtag(tag),
                          backgroundColor: const Color.fromARGB(
                            255,
                            200,
                            234,
                            255,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons container at bottom
            Container(
              padding: const EdgeInsets.only(
                bottom: 50,
                left: 25,
                right: 25,
                top: 10,
              ),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

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

                        DateTime now = DateTime.now();

                        try {
                          if (widget.note != null) {
                            // Update existing note
                            final updatedNote = widget.note!.copywith(
                              title: titleController.text.trim(),
                              content: contentController.text.trim(),
                              starred: isStarred,
                              hashtags: hashtags,
                            );
                            await context.read<NotesCubit>().updateNote(
                              widget.note!.id!,
                              updatedNote,
                            );
                          } else {
                            // Create new note
                            final newNote = Note(
                              title: titleController.text.trim(),
                              starred: isStarred,
                              createdOn: Timestamp.fromDate(now),
                              content: contentController.text.trim(),
                              hashtags: hashtags,
                            );
                            await context.read<NotesCubit>().createNote(
                              newNote,
                            );
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.note != null
                                      ? "Note updated successfully!"
                                      : "Note saved successfully!",
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to save note: $e"),
                              ),
                            );
                          }
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
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
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

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    hashtagController.dispose();
    super.dispose();
  }
}
