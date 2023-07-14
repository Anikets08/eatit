import 'package:cached_network_image/cached_network_image.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/screens/post_view_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileBookmarkGrid extends ConsumerWidget {
  const ProfileBookmarkGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: ref
              .read(firestoreProvider)
              .collection('users')
              .doc(ref.read(authProvider).currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else {
              return snapshot.data!['bookmarks'].isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          FaIcon(
                            FontAwesomeIcons.bookmark,
                            size: 30,
                          ),
                          SizedBox(height: 10),
                          Text('No Bookmark'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: snapshot.data!['bookmarks'].length,
                      itemBuilder: (context, index) {
                        var postData = ref
                            .read(firestoreProvider)
                            .collection('posts')
                            .doc(snapshot.data!['bookmarks'][index])
                            .get();
                        return FutureBuilder(
                          future: postData,
                          builder: (context, data) {
                            if (data.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PostViewScreen(snap: data.data!),
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: data.data!['image'],
                                  fit: BoxFit.fitWidth,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          SizedBox(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    child: const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
            }
          },
        ),
      ),
    );
  }
}
