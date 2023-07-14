import 'dart:io';

import 'package:eatit/features/post/post_repository.dart';
import 'package:eatit/model/comment_model.dart';
import 'package:eatit/model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postControllerProvider = Provider((ref) => PostController(
      postRepository: ref.read(postRepositoryProvider),
    ));

class PostController {
  final PostRepository _postRepository;
  PostController({required PostRepository postRepository})
      : _postRepository = postRepository;

  Future<String> uploadImage(String image, String uid, String postId) async {
    final res = await _postRepository.uploadImage(uid, postId, File(image));
    return res.fold(
      (l) {
        print(l);
        return '';
      },
      (r) => r,
    );
  }

  Future<void> createPost(PostModel post, BuildContext context) async {
    final res = await _postRepository.createPost(post);
    res.fold(
      (l) =>
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
      (r) => print('success'),
    );
  }

  Future<String> likePost(String postId, String userId, List likes) async {
    final res = await _postRepository.likePost(postId, userId, likes);
    return res.fold(
      (l) => '',
      (r) => 'success',
    );
  }

  Future<String> bookmarkPost(
      String postId, String userId, List bookmarks) async {
    final res = await _postRepository.bookmarkPost(postId, userId, bookmarks);
    return res.fold(
      (l) => '',
      (r) => 'success',
    );
  }

  Future<String> deletePost(
      String postId, String userId, BuildContext context) async {
    final res = await _postRepository.deletePost(postId, userId);
    return res.fold(
      (l) => '',
      (r) {
        Navigator.pop(context);
        return 'success';
      },
    );
  }

  Future<String> addComment(CommentModel comment) async {
    final res = await _postRepository.addComment(comment);
    return res.fold(
      (l) => '',
      (r) => 'success',
    );
  }
}
