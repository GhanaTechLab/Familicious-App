import 'dart:io';

import 'package:famlicious_app/services/file_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FileUploadService _fileUploadService = FileUploadService();
  String _message = 'hello';
  bool _isLoading = false;

  String get message => _message; //get
  bool get isLoading => _isLoading;

  setMessage(String message) {
    //setting
    _message = message;
    notifyListeners();
  }

  setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  //email, password
  createNewUser(
      {required String name,
      required String email,
      required String password,
      required File imageFile}) async {
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      String? photoUrl = await _fileUploadService.uploadFile(
          file: imageFile, userUid: userCredential.user!.uid);

      if (photoUrl != null) {
        // add user info to firestore (name,email,photo,uid,createdAt)

        
      } else {
        setMessage('Image upload failed!');
      }
    }).catchError((onError) {
      setMessage('$onError');
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
    });
  }
}
