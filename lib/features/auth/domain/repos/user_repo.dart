import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studymate/features/auth/domain/models/app_user.dart';

class UserRepo extends GetxController {
  static UserRepo get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> createUser(AppUser user) async {
    await _db
        .collection('users')
        .add(user.toJson())
        .whenComplete(
          () => Get.snackbar(
            'Success',
            'Your account has been created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        )
        .catchError((error, stackTrace) {
          Get.snackbar(
            'Error',
            'Something went wrong. Try again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        });
  }
}
