import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/model/comment_model.dart';
import 'package:eatit/model/post_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final postRepositoryProvider = Provider((ref) => PostRepository(
      firestore: ref.read(firestoreProvider),
      storage: ref.read(storageProvider),
    ));

class PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PostRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  Future<Either<String, String>> uploadImage(
      String uid, String postId, File imagePath) async {
    try {
      final imageUri = Uri.parse(imagePath.path);
      final String outputUri = imageUri.resolve('./output.webp').toString();

      XFile? compressed = await FlutterImageCompress.compressAndGetFile(
          imagePath.path, outputUri,
          quality: imagePath.lengthSync() > 3000000
              ? 10
              : imagePath.lengthSync() > 1048576
                  ? 30
                  : 70,
          format: CompressFormat.webp);

      final ref = _storage.ref().child('posts/$uid/$postId');
      await ref.putFile(
        File(compressed!.path),
      );
      final url = await ref.getDownloadURL();
      return right(url);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, String>> createPost(PostModel post) async {
    try {
      _firestore.collection('posts').doc(post.postId).set(post.toJson());
      return right(post.postId);
    } on Firebase catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, String>> likePost(
      String postId, String userId, List likes) async {
    try {
      if (likes.contains(userId)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
      return right(postId);
    } on Firebase catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, String>> bookmarkPost(
      String postId, String userId, List bookmarks) async {
    try {
      if (bookmarks.contains(postId)) {
        await _firestore.collection('users').doc(userId).update({
          'bookmarks': FieldValue.arrayRemove([postId])
        });
      } else {
        await _firestore.collection('users').doc(userId).update({
          'bookmarks': FieldValue.arrayUnion([postId])
        });
      }
      return right(postId);
    } on Firebase catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, String>> deletePost(
      String postId, String userId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      await _storage.ref().child('posts/$userId/$postId').delete();
      await _firestore.collection('users').doc(userId).update({
        'bookmarks': FieldValue.arrayRemove([postId])
      });
      return right(postId);
    } on Firebase catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, String>> addComment(CommentModel commentModel) async {
    try {
      await _firestore
          .collection('posts')
          .doc(commentModel.postId)
          .collection('comments')
          .doc()
          .set(commentModel.toJson());
      return right(commentModel.postId);
    } on Firebase catch (e) {
      return left(e.toString());
    }
  }
}
