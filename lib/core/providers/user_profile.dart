import 'package:eatit/features/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAvatarModel {
  String avatarName;
  String avatarUrl;
  UserAvatarModel({
    required this.avatarName,
    required this.avatarUrl,
  });
}

final userProfileAvatarProvider =
    StateNotifierProvider<UserProfileAvatar, UserAvatarModel>(
  (ref) => UserProfileAvatar(
    ref,
  ),
);

class UserProfileAvatar extends StateNotifier<UserAvatarModel> {
  Ref ref;
  UserProfileAvatar(
    this.ref,
  ) : super(
          UserAvatarModel(
            avatarName: ref.read(userProvider)!.avatarName,
            avatarUrl: ref.read(userProvider)!.avatarName,
          ),
        );

  void updateAvatar(String avatarName, String avatarUrl) {
    state = UserAvatarModel(
      avatarName: avatarName,
      avatarUrl: avatarUrl,
    );
  }
}
