import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String body;
  final List<String> likes;
  final String uid;
  final String image;
  final String? location;
  final Timestamp timestamp;
  final String postId;
  final String profileImage;
  final String fullName;

  PostModel({
    required this.body,
    required this.uid,
    required this.likes,
    required this.image,
    this.location,
    required this.timestamp,
    required this.postId,
    required this.profileImage,
    required this.fullName,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      body: json['body'],
      uid: json['uid'],
      image: json['image'],
      likes: json['likes'],
      location: json['location'],
      timestamp: json['timestamp'],
      postId: json['postId'],
      profileImage: json['profileImage'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'uid': uid,
      'image': image,
      'likes': likes,
      'location': location,
      'timestamp': timestamp,
      'postId': postId,
      'profileImage': profileImage,
      'fullName': fullName,
    };
  }
}
