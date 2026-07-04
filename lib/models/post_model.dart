import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String uid;
  final String username;
  final String profileImage;
  final String title;
  final String location;
  final String category;
  final String caption;
  final String imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.profileImage,
    required this.title,
    required this.location,
    required this.category,
    required this.caption,
    required this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
      "profileImage": profileImage,
      "title": title,
      "location": location,
      "category": category,
      "caption": caption,
      "imageUrl": imageUrl,
      "likesCount": likesCount,
      "commentsCount": commentsCount,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory PostModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return PostModel(
      id: id,
      uid: map["uid"] ?? "",
      username: map["username"] ?? "",
      profileImage: map["profileImage"] ?? "",
      title: map["title"] ?? "",
      location: map["location"] ?? "",
      category: map["category"] ?? "",
      caption: map["caption"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      likesCount: map["likesCount"] ?? 0,
      commentsCount: map["commentsCount"] ?? 0,
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }
}