import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FileUploadService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String?> uploadFile(
      {required File file, required String userUid}) async {
    try {
    
      Reference storageRef =
          _firebaseStorage.ref().child('profile_images').child('$userUid.jpg');

      UploadTask storageUploadTask = storageRef.putFile(file);

      TaskSnapshot snapshot = await storageUploadTask.whenComplete(()=> storageRef.getDownloadURL());

      return await snapshot.ref.getDownloadURL();

    } catch (e) {
      debugPrint('############ $e');
      return null;
    }
  }
}
