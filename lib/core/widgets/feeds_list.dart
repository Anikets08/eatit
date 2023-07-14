import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/constants/avatar_contant.dart';
import 'package:eatit/core/constants/shimmer_loader.dart';
import 'package:eatit/core/providers/bookmark_provider.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/core/providers/subscribed_provider.dart';
import 'package:eatit/core/widgets/feed_widget.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:eatit/screens/add_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedList extends ConsumerStatefulWidget {
  const FeedList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList> {
  @override
  void initState() {
    checkBookMark();
    checkSubscription();
    super.initState();
  }

  void checkBookMark() async {
    try {
      var doc = await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(ref.read(authProvider).currentUser!.uid)
          .get();

      ref.read(bookmarkProvider.notifier).addAllBookmark(doc['bookmarks']);
    } catch (e) {
      print(e);
    }
  }

  void checkSubscription() async {
    try {
      var doc = await ref
          .read(firestoreProvider)
          .collection("users")
          .doc(ref.read(authProvider).currentUser!.uid)
          .get();
      final List list = doc['subscribedTo'];
      final List<Map> lm = list
          .map((e) => {
                e.keys.first: e.values.first,
              })
          .toList();
      ref.read(subscribedProvider.notifier).addAllToList(lm);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref
          .read(firestoreProvider)
          .collection('posts')
          .orderBy(
            'timestamp',
            descending: true,
          )
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerLoaderWidet();
        }
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPostScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
            heroTag: 'fab',
            child: const FaIcon(FontAwesomeIcons.plus),
          ),
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    ref.watch(userProvider)!.avatarName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.8,
                      fontSize: 30,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundImage: AssetImage(
                    AvatarConstant
                        .avatars[
                            int.parse(ref.watch(userProvider)!.avatarImg) - 1]
                        .imageLocal,
                  ),
                ),
              ],
            ),
          ),
          body: snapshot.data!.docs.isEmpty
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      FaIcon(
                        FontAwesomeIcons.images,
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text('No Posts'),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 9999,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[200],
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return FeedWidget(
                      isPostView: false,
                      key: UniqueKey(),
                      snap: snapshot.data!.docs[index].data(),
                    );
                  },
                ),
        );
      },
    );
  }
}
