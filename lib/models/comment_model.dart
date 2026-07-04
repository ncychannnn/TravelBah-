import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String uid;
  final String username;
  final String profileImage;
  final String comment;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.profileImage,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
      "profileImage": profileImage,
      "comment": comment,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CommentModel(
      id: id,
      uid: map["uid"] ?? "",
      username: map["username"] ?? "",
      profileImage: map["profileImage"] ?? "",
      comment: map["comment"] ?? "",
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }
}