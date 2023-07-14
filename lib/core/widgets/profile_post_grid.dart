import 'package:cached_network_image/cached_network_image.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/screens/post_view_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePostGrid extends ConsumerStatefulWidget {
  const ProfilePostGrid({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfilePostGridState();
}

class _ProfilePostGridState extends ConsumerState<ProfilePostGrid> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: ref
              .read(firestoreProvider)
              .collection('posts')
              .where(
                'uid',
                isEqualTo: ref.read(authProvider).currentUser!.uid,
              )
              .orderBy(
                'timestamp',
                descending: false,
              )
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else {
              return (snapshot.data! as dynamic).docs.length == 0
                  ? Center(
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
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data();
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostViewScreen(snap: data),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: data['image'],
                            fit: BoxFit.fitWidth,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => SizedBox(
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
                      },
                    );
            }
          },
        ),
      ),
    );
  }
}
