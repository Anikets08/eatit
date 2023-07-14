import "package:eatit/core/providers/firebase_provider.dart";
import "package:eatit/core/widgets/feeds_list.dart";
import "package:eatit/features/auth/auth_controller.dart";
import 'package:eatit/core/widgets/choose_avatar_poolover.dart';
import "package:eatit/screens/profile_screen.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class HomeScreen extends ConsumerStatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentPageIndex = 0;
  bool showStarterBottomSheet = true;

  void setStarterBottomSheet(bool value) {
    setState(() {
      showStarterBottomSheet = value;
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
        callback: (value) => setStarterBottomSheet(value),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // ref
    //     .read(firestoreProvider)
    //     .collection('users')
    //     .doc(ref.read(authProvider).currentUser!.uid)
    //     .update({
    //   'token': widget.token,
    // });

    var data = ref.read(userProvider)?.isAvatarChoose;
    if (data == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBottomSheet();
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Feed',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: IndexedStack(
              index: currentPageIndex,
              children: const [
                Center(child: FeedList()),
                Center(child: ProfileScreen()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
