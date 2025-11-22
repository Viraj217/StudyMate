// uploading to cloudinary
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> uploadToCloudinary(
  Uint8List fileBytes,
  String filename, {
  String resourceType = 'auto',
}) async {
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  if (cloudName.isEmpty) {
    // On web, dotenv might not be loaded, so we might need a fallback or ensure it's loaded.
    // But for now, we assume it's handled in main.dart or we fail gracefully.
    print("Cloudinary Cloud Name not found in .env");
    // return null; // Let's try to proceed or fail.
  }

  var uri = Uri.parse(
    "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
  );
  var request = http.MultipartRequest("POST", uri);

  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: filename,
  );

  request.files.add(multipartFile);
  request.fields['upload_preset'] = "studymate";
  request.fields['resource_type'] = resourceType;

  try {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("Upload Successful");
      return jsonDecode(responseBody);
    } else {
      print("Upload Failed with ${response.statusCode}: $responseBody");
      return null;
    }
  } catch (e) {
    print("Error uploading to Cloudinary: $e");
    return null;
  }
}
