import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    // Pick image from gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _isUploading = true;
    });

    // Upload to Cloudinary
    final uploadUrl = Uri.parse('https://api.cloudinary.com/v1_1/dgeeyyraa/image/upload');

    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = 'studymate'
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      setState(() {
        _uploadedImageUrl = jsonResp['secure_url'];
        _isUploading = false;
      });
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed with status ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Images')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isUploading
                ? const CircularProgressIndicator()
                : _uploadedImageUrl != null
                    ? Image.network(_uploadedImageUrl!, height: 200)
                    : _imageFile != null
                        ? Image.file(_imageFile!, height: 200)
                        : const Text('No image selected.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
