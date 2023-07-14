import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/screens/add_post_screen.dart';
import 'package:eatit/screens/home_screen.dart';
import 'package:eatit/screens/login_screen.dart';
import 'package:eatit/firebase_options.dart';
import 'package:eatit/screens/profile_screen.dart';
import 'package:eatit/theme/pallete.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:eatit/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final container = ProviderContainer();
  final fMessage = container.read(firebaseMessaging);

  NotificationSettings settings = await fMessage.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional
      ? debugPrint('User granted permission')
      : debugPrint('User declined or has not accepted permission');

  String? token = await fMessage.getToken();
  print("TOKEN: $token");

// listen to foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  runApp(
    ProviderScope(
      child: MyApp(
        token: token!,
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final String token;
  const MyApp({super.key, required this.token});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EatIt',
      theme: ThemeData(
        fontFamily: GoogleFonts.ubuntu().fontFamily,
        useMaterial3: true,
        colorSchemeSeed: Pallete.accentColor,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(
              token: widget.token,
            ),
        '/profile': (context) => const ProfileScreen(),
        '/add_post': (context) => const AddPostScreen(),
      },
    );
  }
}
