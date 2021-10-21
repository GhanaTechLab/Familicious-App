import 'dart:io';

import 'package:famlicious_app/services/file_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  final FileUploadService _fileUploadService = FileUploadService();
  String _message = 'hello';
  bool _isLoading = false;
  CollectionReference userCollection = _firebaseFirestore.collection("users");

  String get message => _message; //getter
  bool get isLoading => _isLoading; //getter

  setMessage(String message) {
    //setter
    _message = message;
    notifyListeners();
  }

  setIsLoading(bool loading) {
    //setter
    _isLoading = loading;
    notifyListeners();
  }

  //email, password
  Future<bool> createNewUser(
      {required String name,
      required String email,
      required String password,
      required File imageFile}) async {
    setIsLoading(true);
    bool isCreated = false;
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      String? photoUrl = await _fileUploadService.uploadFile(
          file: imageFile, userUid: userCredential.user!.uid);

      if (photoUrl != null) {
        await userCollection.doc(userCredential.user!.uid).set({
          "name": name,
          "email": email,
          "picture": photoUrl,
          "createdAt": FieldValue.serverTimestamp(),
          "user_id": userCredential.user!.uid
        });
        isCreated = true;
      } else {
        setMessage('Image upload failed!');
        isCreated = false;
      }
      setIsLoading(false); //set to false
    }).catchError((onError) {
      setMessage('$onError');
      isCreated = false;
      setIsLoading(false); //set to false
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
      isCreated = false;
      setIsLoading(false); //set to false
    });
    return isCreated;
  }

  Future<bool> loginUser(
      {required String email, required String password}) async {
    bool isSuccessful = false;
    await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((userCredential) {
      if (userCredential.user != null) {
        isSuccessful = true;
      } else {
        isSuccessful = false;
        setMessage('Could not log you in!');
      }
    }).catchError((onError) {
      setMessage('$onError');
      isSuccessful = false;
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
      isSuccessful = false;
    });
    return isSuccessful;
  }

  Future<bool> sendResetLink(String email) async {
    bool isSent = false;
    await _firebaseAuth.sendPasswordResetEmail(email: email).then((_) {
      isSent = true;
    }).catchError((onError) {
      setMessage('$onError');
      isSent = false;
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
      isSent = false;
    });
    return isSent;
  }
}
