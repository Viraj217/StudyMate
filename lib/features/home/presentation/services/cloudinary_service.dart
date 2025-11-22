// uploading to cloudinary
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("No file selected");
    return false;
  }

  File file = File(filePickerResult.files.single.path!);
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  // Create a multipath request to upload the file
  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest("POST", uri);

  var fileBytes = await file.readAsBytes();
  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: file.path.split("/").last,
  );

  request.files.add(multipartFile);

  request.fields['upload_preset'] = "studymate";
  request.fields['resource_type'] = "raw";

  // send the request and await the response
  var response = await request.send();

  // Get the response as text
  var responseBody = await response.stream.bytesToString();

  print(responseBody);

  if (response.statusCode == 200) {
    print("Succesful");
    return true;
  } else {
    print("Failed with ${response.statusCode}");
    return false;
  }
}
