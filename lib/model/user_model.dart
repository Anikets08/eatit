class UserModel {
  final String name;
  final String profilePicture;
  final String uid;
  final int foodieLevel;
  final List<dynamic> bookmarks;
  final bool isAvatarChoose;
  final String avatarImg;
  final String avatarName;
  final List<dynamic> subscribedTo;

  UserModel({
    required this.name,
    required this.profilePicture,
    required this.uid,
    required this.foodieLevel,
    required this.bookmarks,
    this.isAvatarChoose = false,
    this.avatarImg = '',
    this.avatarName = '',
    required this.subscribedTo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      profilePicture: json['profilePicture'],
      uid: json['uid'],
      foodieLevel: json['foodieLevel'],
      bookmarks: json['bookmarks'],
      isAvatarChoose: json['isAvatarChoose'],
      avatarImg: json['avatarImg'],
      avatarName: json['avatarName'],
      subscribedTo: json['subscribedTo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'uid': uid,
      'foodieLevel': foodieLevel,
      'bookmarks': bookmarks,
      'isAvatarChoose': isAvatarChoose,
      'avatarImg': avatarImg,
      'avatarName': avatarName,
      'subscribedTo': subscribedTo,
    };
  }
}
