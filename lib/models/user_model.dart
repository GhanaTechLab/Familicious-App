import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';

class UserModel {
  String userId;
  String? name;
  String? email;
  String? picture;
  Timestamp? lastUpdated;

  UserModel({
    required this.userId,
    this.name,
    this.email,
    this.picture,
    this.lastUpdated,
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return UserModel(
      userId: data?["userId"],
      name: data?["name"],
      email: data?["email"],
      picture: data?["picture"],
      lastUpdated: data?["lastUpdated"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "userId": userId,
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (picture != null) "picture": picture,
      "lastUpdated": FieldValue.serverTimestamp(),
    };
  }

  @override
  operator ==(other) =>
      other is UserModel &&
          other.userId == userId &&
          other.name == name &&
          other.email == email &&
          other.picture == picture;

  @override
  int get hashCode => hash4(userId, name, email, picture);
}