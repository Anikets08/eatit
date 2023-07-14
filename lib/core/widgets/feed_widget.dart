import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/constants/avatar_contant.dart';
import 'package:eatit/core/constants/shimmer_loader.dart';
import 'package:eatit/core/providers/bookmark_provider.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/core/providers/subscribed_provider.dart';
import 'package:eatit/core/widgets/like_widget.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:eatit/features/notification/notification_controller.dart';
import 'package:eatit/features/post/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedWidget extends ConsumerStatefulWidget {
  final snap;
  final bool isPostView;

  const FeedWidget({
    Key? key,
    required this.snap,
    required this.isPostView,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends ConsumerState<FeedWidget> {
  String token = '';
  bool loading = false;
  bool isImageLoading = true;
  bool isAnimating = false;

  void addToken() async {
    final token = await ref.read(firebaseMessaging).getToken();
    setState(() {
      this.token = token!;
    });
  }

  void bookmarked() async {
    var data = await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(ref.read(authProvider).currentUser!.uid)
        .get();

    var res = await ref.read(postControllerProvider).bookmarkPost(
        widget.snap['postId'],
        ref.read(authProvider).currentUser!.uid,
        data.data()!['bookmarks']);

    if (res == 'success') {
      if (ref
          .read(bookmarkProvider.notifier)
          .state
          .contains(widget.snap['postId'])) {
        ref
            .read(bookmarkProvider.notifier)
            .removeBookmark(widget.snap['postId']);
      } else {
        ref.read(bookmarkProvider.notifier).addBookmark(widget.snap['postId']);
      }
    }
  }

  void deletePostFun(BuildContext context) async {
    ref
        .read(postControllerProvider)
        .deletePost(widget.snap['postId'], widget.snap['uid'], context);
  }

  void liked(postId, userId) async {
    final firestore = ref.read(firestoreProvider);
    final res = widget.snap['likes'].contains(userId);
    if (res) {
      await firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  @override
  void initState() {
    addToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref
        .read(firestoreProvider)
        .collection("users")
        .doc(widget.snap['uid'])
        .get();
    List<dynamic> bookmarks = ref.watch(bookmarkProvider);
    List<Map> subscriptions = ref.watch(subscribedProvider);
    bool isKeyValuePresent = subscriptions.any((map) =>
        map.containsValue(token.toString()) &&
        map.containsKey(widget.snap['uid']));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                    AvatarConstant
                        .avatars[int.parse(widget.snap['profileImage']) - 1]
                        .imageLocal,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.snap['fullName'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    widget.snap['location'] != ''
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 15,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.snap['location'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                const Spacer(),
                widget.isPostView
                    ? widget.snap['uid'] ==
                            ref.read(authProvider).currentUser?.uid
                        ? IconButton(
                            onPressed: () {
                              deletePostFun(context);
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.trash,
                              size: 18,
                              color: Colors.grey.shade700,
                            ),
                          )
                        : const SizedBox()
                    : const SizedBox(),
                widget.snap['uid'] != ref.read(authProvider).currentUser?.uid
                    ? IconButton(
                        onPressed: () async {
                          if (loading) {
                          } else if (isKeyValuePresent) {
                            setState(() {
                              loading = true;
                            });
                            await ref
                                .read(notificationControllerProvider)
                                .unsubscribeUser(
                                  ref.read(userProvider)!.uid,
                                  widget.snap['uid'],
                                  token.toString(),
                                  context,
                                );
                            ref
                                .read(subscribedProvider.notifier)
                                .removeOne(widget.snap['uid']);
                            setState(() {
                              loading = false;
                            });
                          } else {
                            setState(() {
                              loading = true;
                            });
                            var res = await ref
                                .read(firestoreProvider)
                                .collection('users')
                                .doc(ref.read(authProvider).currentUser!.uid)
                                .get();

                            final List list = res['subscribedTo'];
                            final List<Map> lm = list
                                .map((e) => {
                                      e.keys.first: e.values.first,
                                    })
                                .toList();
                            final indexOfMap = lm.indexWhere((element) =>
                                element.containsKey(widget.snap['uid']));
                            if (indexOfMap == -1) {
                              // ignore: use_build_context_synchronously
                              await ref
                                  .read(notificationControllerProvider)
                                  .subscribeToNotification(
                                    widget.snap["uid"],
                                    ref.read(userProvider)!.uid,
                                    token.toString(),
                                    context,
                                  );
                              ref.read(subscribedProvider.notifier).addOne(
                                    widget.snap['uid'],
                                    token.toString(),
                                  );
                            } else {
                              final val = lm[indexOfMap].values.first;
                              // ignore: use_build_context_synchronously
                              await ref
                                  .read(notificationControllerProvider)
                                  .unsubscribeUser(
                                    ref.read(userProvider)!.uid,
                                    widget.snap['uid'],
                                    val,
                                    context,
                                  );
                            }
                            // ignore: use_build_context_synchronously
                            await ref
                                .read(notificationControllerProvider)
                                .subscribeToNotification(
                                  widget.snap["uid"],
                                  ref.read(userProvider)!.uid,
                                  token.toString(),
                                  context,
                                );
                            ref.read(subscribedProvider.notifier).addOne(
                                  widget.snap['uid'],
                                  token.toString(),
                                );
                            setState(() {
                              loading = false;
                            });
                          }
                          setState(() {
                            loading = false;
                          });
                        },
                        icon: FaIcon(
                          loading
                              ? FontAwesomeIcons.spinner
                              : isKeyValuePresent
                                  ? Icons.notifications_active
                                  : FontAwesomeIcons.bell,
                          size: isKeyValuePresent ? 25 : 20,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onDoubleTap: () {
              widget.isPostView
                  ? null
                  : {
                      liked(
                        widget.snap['postId'],
                        ref.read(authProvider).currentUser!.uid,
                      ),
                    };
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    imageUrl: widget.snap['image'],
                    fit: BoxFit.fitWidth,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            const ShimmerLoaderContainer(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LikeWidget(
              snap: widget.snap,
              isPostView: widget.isPostView,
              bookmarks: bookmarks,
              liked: liked,
              bookmarked: bookmarked),
          const SizedBox(height: 5),
          widget.snap['body'] != ''
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    widget.snap['body'],
                    style: TextStyle(
                      color: Colors.grey[1000],
                      fontSize: 13,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

// AnimatedOpacity(
//   opacity: isAnimating ? 1 : 0,
//   duration: const Duration(milliseconds: 200),
//   child: LikeAnimationWidget(
//     isAnimating: isAnimating,
//     duration: const Duration(milliseconds: 400),
//     // onEnd: () {
//     //   setState(() {
//     //     isAnimating = false;
//     //   });
//     // },
//     child: const FaIcon(
//       FontAwesomeIcons.solidHeart,
//       size: 100,
//       color: Colors.red,
//     ),
//   ),
// ),

// AnimatedOpacity(
//   opacity: isAnimating ? 1 : 0,
//   duration: const Duration(milliseconds: 200),
//   child: const FaIcon(
//     FontAwesomeIcons.solidHeart,
//     size: 100,
//     color: Colors.red,
//   ),
// )
