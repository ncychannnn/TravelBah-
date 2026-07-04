import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==========================
  /// CREATE POST
  /// ==========================
  Future<void> createPost(PostModel post) async {
    await _firestore
        .collection("posts")
        .doc(post.id)
        .set(post.toMap());
  }

  /// ==========================
/// UPDATE POST
/// ==========================
Future<void> updatePost(PostModel post) async {
  await _firestore
      .collection("posts")
      .doc(post.id)
      .update({
    "title": post.title,
    "location": post.location,
    "category": post.category,
    "caption": post.caption,
    "imageUrl": post.imageUrl,
  });
}

  /// ==========================
  /// GET POSTS
  /// ==========================
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PostModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

/// ==========================
/// DELETE POST
/// ==========================
Future<void> deletePost(String postId) async {
  final postRef = _firestore.collection("posts").doc(postId);

  // Delete comments
  final comments = await postRef.collection("comments").get();
  for (final doc in comments.docs) {
    await doc.reference.delete();
  }

  // Delete likes
  final likes = await postRef.collection("likes").get();
  for (final doc in likes.docs) {
    await doc.reference.delete();
  }

  // Delete the post
  await postRef.delete();
}

  /// ==========================
  /// UPDATE LIKE COUNT
  /// ==========================
  Future<void> updateLikes(
    String postId,
    int likes,
  ) async {
    await _firestore
        .collection("posts")
        .doc(postId)
        .update({
      "likesCount": likes,
    });
  }

  /// ==========================
  /// UPDATE COMMENT COUNT
  /// ==========================
  Future<void> updateComments(
    String postId,
    int comments,
  ) async {
    await _firestore
        .collection("posts")
        .doc(postId)
        .update({
      "commentsCount": comments,
    });
  }

  /// ==========================
  /// LIKE / UNLIKE POST
  /// ==========================
  Future<void> toggleLike(
    String postId,
    String userId,
  ) async {
    final postRef = _firestore
        .collection("posts")
        .doc(postId);

    final likeRef = postRef
        .collection("likes")
        .doc(userId);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      final likeSnapshot = await transaction.get(likeRef);

      int likesCount =
          postSnapshot.data()?["likesCount"] ?? 0;

      if (likeSnapshot.exists) {
        transaction.delete(likeRef);

        transaction.update(postRef, {
          "likesCount": likesCount - 1,
        });
      } else {
        transaction.set(likeRef, {
          "likedAt": FieldValue.serverTimestamp(),
        });

        transaction.update(postRef, {
          "likesCount": likesCount + 1,
        });
      }
    });
  }

  /// ==========================
  /// CHECK IF USER HAS LIKED
  /// ==========================
  Stream<bool> hasLiked(
    String postId,
    String userId,
  ) {
    return _firestore
        .collection("posts")
        .doc(postId)
        .collection("likes")
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// ==========================
  /// ADD COMMENT
  /// ==========================
  Future<void> addComment(
    String postId,
    CommentModel comment,
  ) async {
    final postRef = _firestore
        .collection("posts")
        .doc(postId);

    await postRef
        .collection("comments")
        .doc(comment.id)
        .set(comment.toMap());

    final postSnapshot = await postRef.get();

    int count = postSnapshot["commentsCount"] ?? 0;

    await postRef.update({
      "commentsCount": count + 1,
    });
  }

  /// ==========================
  /// GET COMMENTS
  /// ==========================
  Stream<List<CommentModel>> getComments(
    String postId,
  ) {
    return _firestore
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommentModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// ==========================
  /// EDIT COMMENT
  /// ==========================
  Future<void> editComment(
    String postId,
    String commentId,
    String newComment,
  ) async {
    await _firestore
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .update({
      "comment": newComment,
    });
  }

  /// ==========================
  /// DELETE COMMENT
  /// ==========================
  Future<void> deleteComment(
    String postId,
    String commentId,
  ) async {
    final postRef = _firestore
        .collection("posts")
        .doc(postId);

    await postRef
        .collection("comments")
        .doc(commentId)
        .delete();

    final postSnapshot = await postRef.get();

    int count = postSnapshot["commentsCount"] ?? 0;

    if (count > 0) {
      await postRef.update({
        "commentsCount": count - 1,
      });
    }
  }

  /// ==========================
  /// SAVE TO WISHLIST
  /// ==========================
  Future<void> savePost(
    String uid,
    String postId,
  ) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("wishlist")
        .doc(postId)
        .set({
      "savedAt": Timestamp.now(),
    });
  }

  /// ==========================
  /// REMOVE FROM WISHLIST
  /// ==========================
  Future<void> removeSavedPost(
    String uid,
    String postId,
  ) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("wishlist")
        .doc(postId)
        .delete();
  }

  /// ==========================
  /// CHECK IF SAVED
  /// ==========================
  Stream<bool> isSaved(
    String uid,
    String postId,
  ) {
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("wishlist")
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// ==========================
/// GET WISHLIST POSTS
/// ==========================
Stream<List<PostModel>> getWishlistPosts(String uid) {
  return _firestore
      .collection("users")
      .doc(uid)
      .collection("wishlist")
      .snapshots()
      .asyncMap((wishlistSnapshot) async {
    if (wishlistSnapshot.docs.isEmpty) {
      return <PostModel>[];
    }

    List<PostModel> posts = [];

    for (final wishlistDoc in wishlistSnapshot.docs) {
      final postDoc = await _firestore
          .collection("posts")
          .doc(wishlistDoc.id)
          .get();

      if (postDoc.exists) {
        posts.add(
          PostModel.fromMap(
            postDoc.data()!,
            postDoc.id,
          ),
        );
      }
    }

    return posts;
  });
}

/// ==========================
/// GET TOTAL LIKES RECEIVED
/// ==========================
Stream<int> getTotalLikes(String uid) {
  return _firestore
      .collection("posts")
      .where("uid", isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
    int totalLikes = 0;

    for (final doc in snapshot.docs) {
      totalLikes +=
          (doc.data()["likesCount"] ?? 0) as int;
    }

    return totalLikes;
  });
}

/// ==========================
/// GET CURRENT USER
/// ==========================
Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser(
  String uid,
) {
  return _firestore
      .collection("users")
      .doc(uid)
      .snapshots();
}

/// ==========================
/// GET MY POSTS
/// ==========================
Stream<List<PostModel>> getMyPosts(
  String uid,
) {
  return _firestore
      .collection("posts")
      .where("uid", isEqualTo: uid)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => PostModel.fromMap(
                doc.data(),
                doc.id,
              ),
            )
            .toList(),
      );
}

/// ==========================
/// GET WISHLIST COUNT
/// ==========================
Stream<int> getWishlistCount(
  String uid,
) {
  return _firestore
      .collection("users")
      .doc(uid)
      .collection("wishlist")
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.length,
      );
}

/// ==========================
/// UPDATE USERNAME
/// ==========================
Future<void> updateUsername(
  String uid,
  String newUsername,
) async {
  // Update user profile
  await _firestore
      .collection("users")
      .doc(uid)
      .update({
    "name": newUsername,
  });

  // Update username in all posts
  final posts = await _firestore
      .collection("posts")
      .where("uid", isEqualTo: uid)
      .get();

  for (final doc in posts.docs) {
    await doc.reference.update({
      "username": newUsername,
    });
  }
}

/// ==========================
/// UPDATE PROFILE PICTURE
/// ==========================
Future<void> updateProfilePicture(
  String uid,
  String imageUrl,
) async {
  // Update user document
  await _firestore
      .collection("users")
      .doc(uid)
      .update({
    "profileImage": imageUrl,
  });

  // Update all user's posts
  final posts = await _firestore
      .collection("posts")
      .where("uid", isEqualTo: uid)
      .get();

  for (final doc in posts.docs) {
    await doc.reference.update({
      "profileImage": imageUrl,
    });
  }
}

/// ==========================
/// REMOVE PROFILE PICTURE
/// ==========================
Future<void> removeProfilePicture(
  String uid,
) async {

  // Update user document
  await _firestore
      .collection("users")
      .doc(uid)
      .update({
    "profileImage": "",
  });

  // Update all user's posts
  final posts = await _firestore
      .collection("posts")
      .where("uid", isEqualTo: uid)
      .get();

  for (final doc in posts.docs) {
    await doc.reference.update({
      "profileImage": "",
    });
  }
}
}