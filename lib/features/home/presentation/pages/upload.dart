// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:studymate/features/auth/domain/models/study_material.dart';
import 'package:studymate/features/auth/domain/services/database_service.dart';
import 'package:studymate/features/home/presentation/services/cloudinary_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final databaseService _dbService = databaseService();
  final TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => _UploadDialog(dbService: _dbService),
    );
  }

  List<StudyMaterial> _filterMaterials(List<StudyMaterial> materials) {
    var filtered = materials.where((material) {
      if (_searchQuery.isEmpty) return true;
      return material.fileName.toLowerCase().contains(_searchQuery) ||
          material.fileType.toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
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
              const SizedBox(height: 30),
              _isSearching ? _buildSearchBar() : _buildHeader(name),
              const SizedBox(height: 30),

              // Title and Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Study Materials',
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
                      onPressed: _showUploadDialog,
                      icon: const Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Materials List
              Expanded(
                child: user == null
                    ? const Center(
                        child: Text('Please log in to view materials'),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: _dbService.getMaterials(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No materials uploaded yet',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          var materials = snapshot.data!.docs
                              .map((doc) => doc.data() as StudyMaterial)
                              .toList();

                          var filteredMaterials = _filterMaterials(materials);

                          if (filteredMaterials.isEmpty) {
                            return Center(
                              child: Text(
                                'No materials match your search',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredMaterials.length,
                            itemBuilder: (context, index) {
                              return _buildMaterialCard(
                                filteredMaterials[index],
                              );
                            },
                          );
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
              hintText: 'Search materials...',
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              searchController.clear();
            });
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(StudyMaterial material) {
    bool isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
    ].contains(material.fileType.toLowerCase());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _openFile(material.fileUrl),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Preview Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[100],
                child: isImage
                    ? CachedNetworkImage(
                        imageUrl: material.fileUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: const Color.fromARGB(255, 144, 202, 238),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildPlaceholder(material.fileType),
                      )
                    : _buildPlaceholder(material.fileType),
              ),
            ),

            // File Info Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getFileIcon(material.fileType),
                        color: const Color.fromARGB(255, 144, 202, 238),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.fileName,
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              material.fileType.toUpperCase(),
                              style: GoogleFonts.ubuntu(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Uploaded: ${DateFormat('dd MMM yyyy, h:mm a').format(material.createdAt.toDate())}',
                    style: GoogleFonts.ubuntu(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  Widget _buildPlaceholder(String fileType) {
    return Container(
      color: const Color.fromARGB(255, 240, 248, 255),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileIcon(fileType),
              size: 64,
              color: const Color.fromARGB(255, 144, 202, 238),
            ),
            const SizedBox(height: 8),
            Text(
              fileType.toUpperCase(),
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 144, 202, 238),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to open',
              style: GoogleFonts.ubuntu(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _openFile(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   try {
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('Could not open file')));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Error opening file')));
  //   }
  // }
  Future<void> _openFile(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {

        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
           throw 'Could not launch $url';
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e'); // Print error to console for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// Upload Dialog Widget
class _UploadDialog extends StatefulWidget {
  final databaseService dbService;

  const _UploadDialog({required this.dbService});

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final List<FileItem> _files = [];
  bool _isPicking = false;

  Future<void> _pickFiles() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _files.addAll(
            result.paths
                .where((path) => path != null)
                .map((path) => FileItem(file: File(path!))),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
    } finally {
      setState(() => _isPicking = false);
    }
  }

  Future<void> _uploadFile(FileItem item) async {
    setState(() => item.isUploading = true);

    try {
      String extension = item.file.path.split('.').last.toLowerCase();
      String resourceType = ['jpg', 'jpeg', 'png', 'gif'].contains(extension)
          ? 'image'
          : 'auto';

      final result = await uploadToCloudinary(
        item.file,
        resourceType: resourceType,
      );

      if (result != null) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final material = StudyMaterial(
            uid: user.uid,
            fileName: item.file.path.split('/').last,
            fileUrl: result['secure_url'],
            fileType: extension,
            hash: null,
            publicId: result['public_id'],
            createdAt: Timestamp.now(),
          );

          await widget.dbService.addMaterial(material);
        }

        setState(() {
          item.isUploaded = true;
          item.uploadedUrl = result['secure_url'];
          item.publicId = result['public_id'];
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload successful!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading: $e')));
    } finally {
      setState(() => item.isUploading = false);
    }
  }

  void _removeFile(FileItem item) {
    setState(() {
      _files.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload Materials',
                  style: GoogleFonts.ubuntu(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _files.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No files selected',
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _pickFiles,
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: Text(
                              'Select Files',
                              style: GoogleFonts.ubuntu(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                144,
                                202,
                                238,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final item = _files[index];
                        return _buildFileCard(item);
                      },
                    ),
            ),
            if (_files.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.add),
                      label: const Text('Add More'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          144,
                          202,
                          238,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.ubuntu(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(FileItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.file.path.split('/').last,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _removeFile(item),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!item.isUploaded && !item.isUploading)
                  ElevatedButton.icon(
                    onPressed: () => _uploadFile(item),
                    icon: const Icon(
                      Icons.cloud_upload,
                      size: 16,
                      color: Colors.black,
                    ),
                    label: Text(
                      'Upload',
                      style: GoogleFonts.ubuntu(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 144, 202, 238),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                if (item.isUploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (item.isUploaded)
                  const Chip(
                    label: Text('Uploaded', style: TextStyle(fontSize: 12)),
                    avatar: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FileItem {
  final File file;
  String? uploadedUrl;
  String? publicId;
  bool isUploading = false;
  bool isUploaded = false;

  FileItem({required this.file});
}
