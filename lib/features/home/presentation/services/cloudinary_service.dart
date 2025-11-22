// uploading to cloudinary
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> uploadToCloudinary(
  File file, {
  String resourceType = 'auto',
}) async {
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  if (cloudName.isEmpty) {
    print("Cloudinary Cloud Name not found in .env");
    return null;
  }

  var uri = Uri.parse(
    "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
  );
  var request = http.MultipartRequest("POST", uri);

  var fileBytes = await file.readAsBytes();
  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: file.path.split("/").last,
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
