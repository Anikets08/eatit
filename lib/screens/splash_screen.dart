import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:eatit/model/user_model.dart';
import 'package:eatit/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      if (ref.read(authProvider).currentUser != null) {
        DocumentSnapshot documentSnapshot = await ref
            .read(firestoreProvider)
            .collection("users")
            .doc(ref.read(authProvider).currentUser!.uid)
            .get();

        ref.read(userProvider.notifier).update((state) {
          UserModel userModel;
          userModel = UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          state = userModel;
          return state;
        });
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.accentColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Eat It',
              style: GoogleFonts.ubuntu(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Strictly for Foodies :)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
