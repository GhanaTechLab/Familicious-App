import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:famlicious_app/models/user_model.dart';
import 'package:famlicious_app/services/file_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:famlicious_app/services/user_service.dart';

class AuthManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FileUploadService _fileUploadService = FileUploadService();
  final UserService _userService = UserService();
  final CollectionReference userCollection = _firebaseFirestore.collection("users");
  final currentUserStream = StreamController<UserModel?>.broadcast();
  String _message = '';
  UserModel? _currentUser;
  String get message => _message;

  AuthManager() {
    currentUserStream.onListen = () {
      currentUserStream.add(_currentUser);
    };
    _firebaseAuth.authStateChanges().listen((user) async {
      if (user != null) {
        _currentUser = await _userService.retrieve(user.uid);
        if(_currentUser != null) {
          currentUserStream.add(_currentUser);
        }
        notifyListeners();
        log("auth");
      }
    });
  }

  setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  //email, password
  Future<bool> createNewUser({
    required String name,
    required String email,
    required String password,
    required File imageFile
  }) async {
    bool isCreated = false;
    try {
      final firebaseCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      String? photoUrl = await _fileUploadService.uploadFile(
          file: imageFile,
          userUid: firebaseCredential.user!.uid
      );

      if (photoUrl != null) {
        _currentUser = await _userService.create(
            UserModel(
              userId: firebaseCredential.user!.uid,
              name: name,
              email: email,
              picture: photoUrl,
            )
        );
        currentUserStream.add(_currentUser);
        isCreated = true;
      } else {
        setMessage('Image upload failed!');
        _currentUser = null;
        currentUserStream.add(_currentUser);
      }
    } catch(error, stack) {
      setMessage('$error');
      log("Exception creating new user from email.", error: error, stackTrace: stack);
    }
    return isCreated;
  }

  Future<bool> loginUser({required String email, required String password}) async {
    bool isSuccessful = false;
    try {
      final firebaseCreds = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (firebaseCreds.user != null) {
        isSuccessful = true;
      } else {
        _currentUser = null;
        currentUserStream.add(_currentUser);
        setMessage('Could not log you in!');
      }
    } catch(error, stack) {
      log("Exception in loginUser", error: error, stackTrace: stack);
      _currentUser = null;
      currentUserStream.add(_currentUser);
      setMessage('Could not log you in!');
    }

    return isSuccessful;
  }

  Future<bool> googleLogin() async {
    try {
      final googleSignInAccount = await GoogleSignIn().signIn();
      final googleAuth = await googleSignInAccount?.authentication;
      final googleCreds = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final firebaseCreds = await FirebaseAuth.instance.signInWithCredential(
          googleCreds
      );
      if (firebaseCreds.user != null && _currentUser == null) {
        var user = await _userService.retrieve(firebaseCreds.user!.uid);
        if(user == null) {
          _currentUser = await _userService.create(
              UserModel(
                userId: firebaseCreds.user!.uid,
                name: googleSignInAccount?.displayName,
                email: googleSignInAccount?.email,
                picture: googleSignInAccount?.photoUrl,
              )
          );
          currentUserStream.add(_currentUser);
        }
      }
    } catch(error, stack) {
      log("Exception in googleLogin", error: error, stackTrace: stack);
      _currentUser = null;
      currentUserStream.add(_currentUser);
      setMessage('Could not log you in!');
      return false;
    }

    return true;
  }

  Future<bool> facebookLogin() async {
    try {
      var result = await FacebookAuth.i.login(
        permissions: ["public_profile", "email"],
      );

      if (result.status == LoginStatus.success && result.accessToken?.token != null) {
        final responseData = await FacebookAuth.i.getUserData(
          fields: "email, name, picture",
        );
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(
            result.accessToken!.token
        );
        final firebaseCreds = await FirebaseAuth.instance.signInWithCredential(
            facebookAuthCredential
        );
        if (firebaseCreds.user != null && _currentUser == null) {
          _currentUser = await _userService.create(
              UserModel(
                userId: firebaseCreds.user!.uid,
                name: responseData["name"],
                email: responseData["email"],
                picture: responseData["picture"]["data"]["url"],
              )
          );
          currentUserStream.add(_currentUser);
        }
      } else {
        _currentUser = null;
        currentUserStream.add(_currentUser);
        setMessage('Could not log you in!');
        return false;
      }
    } catch(error, stack) {
      log("Exception in facebookLogin", error: error, stackTrace: stack);
      _currentUser = null;
      currentUserStream.add(_currentUser);
      setMessage('Could not log you in!');
      return false;
    }

    return true;
  }

  Future<void> signOut() {
    _currentUser = null;
    currentUserStream.add(_currentUser);
    return _firebaseAuth.signOut();
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
