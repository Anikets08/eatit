import 'package:eatit/core/widgets/sign_in_button.dart';
import 'package:eatit/core/constants/constants.dart';
import 'package:eatit/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int currentIndex = 0;
  int length = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.accentColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView(
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  Image.asset(
                    Constants.illustrationPath1,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    Constants.illustrationPath2,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    Constants.illustrationPath3,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                length,
                (index) => Container(
                  margin: const EdgeInsets.all(5),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "Eat\nShare\n& Scroll",
                textAlign: TextAlign.start,
                style: GoogleFonts.ubuntu(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 0.95,
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: SignInButton(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
