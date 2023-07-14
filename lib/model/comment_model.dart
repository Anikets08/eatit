import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userName;
  final String uid;
  final String comment;
  final String profileImage;
  final Timestamp timestamp;
  final String postId;

  CommentModel({
    required this.userName,
    required this.uid,
    required this.comment,
    required this.profileImage,
    required this.timestamp,
    required this.postId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userName: json['userName'],
      uid: json['uid'],
      comment: json['comment'],
      profileImage: json['profileImage'],
      timestamp: json['timestamp'],
      postId: json['postId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'uid': uid,
      'comment': comment,
      'profileImage': profileImage,
      'timestamp': timestamp,
      'postId': postId,
    };
  }
}
