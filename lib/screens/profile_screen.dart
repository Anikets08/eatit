import 'package:eatit/core/constants/avatar_contant.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/core/widgets/choose_avatar_poolover.dart';
import 'package:eatit/core/widgets/profile_bookmarks_grid.dart';
import 'package:eatit/core/widgets/profile_post_grid.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showPoolover = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void signOut(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signOut(context);
  }

  void setShowPoolover(bool value) {
    setState(() {
      showPoolover = value;
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      context: context,
      builder: (context) => Popover(
        callback: (value) => setShowPoolover(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => signOut(ref, context),
            child: const Icon(Icons.logout),
          ),
          body: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: <Color>[
                            Color(0xff1f005c),
                            Color(0xff5b0060),
                            Color(0xff870160),
                            Color(0xffac255e),
                            Color(0xffca485c),
                            Color(0xffe16b5c),
                            Color(0xfff39060),
                            Color(0xffffb56b),
                          ],
                          tileMode: TileMode.mirror,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            AvatarConstant
                                .avatars[int.parse(
                                        ref.read(userProvider)!.avatarImg) -
                                    1]
                                .imageLocal,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(userProvider)!.avatarName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.8,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '${ref.watch(authProvider).currentUser!.email}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => showBottomSheet(),
                          icon: const Icon(
                            FontAwesomeIcons.pen,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      tabs: [
                        Tab(
                          child: Text(
                            'Posts',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Bookmarks',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      controller: _tabController,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          ProfilePostGrid(),
                          ProfileBookmarkGrid(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        // showPoolover
        //     ? Popover(
        //         callback: (value) => setShowPoolover(value),
        //       )
        //     : const SizedBox(),
      ],
    );
  }
}
