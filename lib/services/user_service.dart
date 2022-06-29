import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famlicious_app/models/user_model.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection("users");

  Future<UserModel?> create(UserModel user) async {
    await users.doc(user.userId).set(user.toFirestore());
    return user;
  }

  Future<UserModel?> retrieve(String userId) async {
    QuerySnapshot<Map<String, dynamic>> snap = await users.where(
        "userId",
        isEqualTo: userId
    ).get();

    return snap.docs.isEmpty
        ? null
        : UserModel.fromFirestore(snap.docs.first, null);
  }
}