import 'package:eatit/core/constants/constants.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInButton extends ConsumerWidget {
  const SignInButton({Key? key}) : super(key: key);

  void signInWithGoogle(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    print("isloading");
    print(isLoading);
    return isLoading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "Geting you inside...",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                ),
              )
            ],
          )
        : ElevatedButton.icon(
            onPressed: () => signInWithGoogle(ref, context),
            icon: Image.asset(Constants.googleImagePath, width: 30),
            label: const Text(
              "Continue with Google",
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
  }
}
