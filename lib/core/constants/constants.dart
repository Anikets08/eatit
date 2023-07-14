import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const logoPath = "assets/logo.png";
  static const googleImagePath = "assets/google.png";
  static const illustrationPath = "assets/food.png";
  static const illustrationPath1 = "assets/img1.jpeg";
  static const illustrationPath2 = "assets/img2.jpeg";
  static const illustrationPath3 = "assets/img3.jpeg";
  static var baseUrl = dotenv.env['BASEURL'].toString();
  static var UNSUB_PATH = dotenv.env['UNSUBPATH'].toString();
  static var SUB_PATH = dotenv.env['SUBPATH'].toString();
  static var NOTIFY_PATH = dotenv.env['NOTIFYPATH'].toString();
}
