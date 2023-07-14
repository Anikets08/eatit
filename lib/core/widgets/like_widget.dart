import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/screens/post_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

class LikeWidget extends ConsumerWidget {
  final snap;
  final isPostView;
  final List bookmarks;
  final Function liked;
  final Function bookmarked;

  const LikeWidget({
    super.key,
    required this.snap,
    required this.isPostView,
    required this.bookmarks,
    required this.liked,
    required this.bookmarked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          LikeButton(
            onTap: (isLiked) {
              liked(
                snap['postId'],
                ref.read(authProvider).currentUser!.uid,
              );
              return Future.value(!isLiked);
            },
            likeCount: snap['likes'].length,
            isLiked:
                snap['likes'].contains(ref.read(authProvider).currentUser?.uid),
            likeBuilder: (isLiked) {
              return Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black,
                size: 25,
              );
            },
          ),
          const SizedBox(width: 0),
          isPostView == false
              ? IconButton(
                  onPressed: () {
                    isPostView
                        ? () {}
                        : Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostViewScreen(
                                snap: snap,
                                key: UniqueKey(),
                              ),
                            ),
                          );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.message,
                    size: 20,
                    color: Colors.black,
                  ),
                )
              : const SizedBox(),
          const Spacer(),
          Text(
            DateFormat.yMMMd().format(
              snap['timestamp'].toDate(),
            ),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              bookmarked();
            },
            icon: FaIcon(
              bookmarks.contains(snap['postId'])
                  ? FontAwesomeIcons.solidBookmark
                  : FontAwesomeIcons.bookmark,
              size: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
