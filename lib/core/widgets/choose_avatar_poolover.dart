import 'package:eatit/core/constants/avatar_contant.dart';
import 'package:eatit/core/providers/firebase_provider.dart';

import 'package:eatit/features/auth/auth_controller.dart';
import 'package:eatit/model/user_model.dart';
import 'package:eatit/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Popover extends ConsumerStatefulWidget {
  final Function callback;
  const Popover({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  PopoverState createState() => PopoverState();
}

class PopoverState extends ConsumerState<Popover> {
  late int currentIndex;
  final TextEditingController _userIdController = TextEditingController();
  bool isLoading = false;
  bool isDone = false;

  void save() async {
    setState(() {
      isLoading = true;
    });
    await ref
        .read(firestoreProvider)
        .collection("users")
        .doc(ref.read(authProvider).currentUser!.uid)
        .update({
      "isAvatarChoose": true,
      "avatarImg": (currentIndex + 1).toString(),
      "avatarName": _userIdController.text,
    });

    ref.read(userProvider.notifier).update((state) {
      UserModel user = UserModel(
        name: state!.name,
        profilePicture: state.profilePicture,
        uid: state.uid,
        foodieLevel: state.foodieLevel,
        bookmarks: state.bookmarks,
        avatarImg: (currentIndex + 1).toString(),
        avatarName: _userIdController.text,
        isAvatarChoose: true,
        subscribedTo: state.subscribedTo,
      );
      state = user;
      return user;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      isLoading = false;
      isDone = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    Navigator.pop(context);
  }

  void change() {
    String cRef = ref.watch(userProvider)!.avatarName;
    print("set state called");
    setState(() {
      _userIdController.text = cRef;
      currentIndex = int.parse(ref.watch(userProvider)!.avatarImg) - 1;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      change();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AvatarConstant.avatars.length,
                controller: PageController(
                  viewportFraction: 0.35,
                  initialPage: currentIndex,
                ),
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                    // vibrate
                    HapticFeedback.heavyImpact();
                  });
                },
                itemBuilder: (context, index) {
                  return UnconstrainedBox(
                    child: CircleAvatar(
                      radius: currentIndex == index ? 60 : 38,
                      backgroundImage: AssetImage(
                        AvatarConstant.avatars[index].imageLocal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Choose your Identity",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                fontSize: 18,
              ),
            ),
            Text(
              "If you don't choose, we will choose for you",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: Pallete.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _userIdController,
                maxLength: 8,
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                save();
                setState(() {
                  isDone = false;
                });
              },
              child: isLoading
                  ? Hero(
                      tag: "loading",
                      child: FittedBox(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Pallete.accentColor,
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : isDone
                      ? Hero(
                          tag: "loading",
                          child: FittedBox(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Pallete.accentColor,
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Done',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 15),
                                  FaIcon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Hero(
                          tag: "loading",
                          child: FittedBox(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Pallete.accentColor,
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 15),
                                  FaIcon(
                                    FontAwesomeIcons.arrowRight,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
