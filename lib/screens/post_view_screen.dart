import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/core/widgets/feed_widget.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:eatit/features/post/post_controller.dart';
import 'package:eatit/model/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostViewScreen extends ConsumerStatefulWidget {
  final snap;
  const PostViewScreen({super.key, required this.snap});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends ConsumerState<PostViewScreen> {
  TextEditingController commentController = TextEditingController();
  void addComment() {
    ref.read(postControllerProvider).addComment(
          CommentModel(
            userName: ref.read(userProvider)!.avatarName,
            uid: ref.read(authProvider).currentUser!.uid,
            comment: commentController.text,
            profileImage: ref.read(authProvider).currentUser!.photoURL!,
            timestamp: Timestamp.now(),
            postId: widget.snap['postId'],
          ),
        );

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Post",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.only(left: 0.0, right: 0, bottom: 100),
                children: [
                  FeedWidget(
                    isPostView: true,
                    snap: widget.snap,
                  ),
                  StreamBuilder(
                    stream: ref
                        .read(firestoreProvider)
                        .collection('posts')
                        .doc(widget.snap['postId'])
                        .collection('comments')
                        .orderBy(
                          'timestamp',
                          descending: true,
                        )
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                snapshot.data!.docs[index]['userName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${snapshot.data!.docs[index]['timestamp'].toDate().day}-${snapshot.data!.docs[index]['timestamp'].toDate().month}-${snapshot.data!.docs[index]['timestamp'].toDate().year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    // 12 hours format
                                    '${snapshot.data!.docs[index]['timestamp'].toDate().hour}:${snapshot.data!.docs[index]['timestamp'].toDate().minute}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                snapshot.data!.docs[index]['comment'],
                              ),
                            );
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: commentController,
                      onSubmitted: (value) {
                        addComment();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Add Comment',
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
