import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/constants/constants.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/core/widgets/loader_widget.dart';
import 'package:eatit/features/auth/auth_controller.dart';
import 'package:eatit/features/post/post_controller.dart';
import 'package:eatit/model/post_model.dart';
import 'package:eatit/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  bool isLoading = false;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  File? _image;
  String? _imagePath;
  final ImagePicker picker = ImagePicker();

  void getimage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _imagePath = image.path;
      });
    } else {
      setState(() {
        _imagePath = '';
      });
    }
  }

  void uploadPost() async {
    setState(() {
      isLoading = true;
    });
    String postUuidId = Uuid().v4();
    String url = await ref.read(postControllerProvider).uploadImage(
        _imagePath!, ref.read(authProvider).currentUser!.uid, postUuidId);
    if (url != '') {
      // ignore: use_build_context_synchronously
      await ref.read(postControllerProvider).createPost(
            PostModel(
              body: _captionController.text,
              uid: ref.read(authProvider).currentUser!.uid,
              likes: [],
              image: url,
              timestamp: Timestamp.now(),
              postId: postUuidId,
              location: _locationController.text,
              profileImage: ref.read(userProvider)!.avatarImg,
              fullName: ref.read(userProvider)!.avatarName,
            ),
            context,
          );
    }
    await sendNotification();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> sendNotification() async {
    print("${Constants.baseUrl}${Constants.NOTIFY_PATH}");
    print("inside send notification");
    await http
        .post(
      Uri.parse("${Constants.baseUrl}${Constants.NOTIFY_PATH}"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(
        {
          "title": "Craving 🤤 Alert!",
          "body":
              "${ref.read(userProvider)!.avatarName} just posted a new food",
          "topic": ref.read(authProvider).currentUser!.uid,
        },
      ),
    )
        .then((value) {
      print("inside send notification");
      print(value.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Add Post',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                letterSpacing: -1.8,
                fontSize: 30,
              ),
            ),
          ),
          body: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              getimage();
                            },
                            child: _image != null
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 500,
                                    ),
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )),
                                  )
                                : Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        size: 35,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Enter Location'),
                                    content: TextField(
                                      controller: _locationController,
                                      decoration: const InputDecoration(
                                        labelText: "Location",
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 15,
                              ),
                              label: Text(_locationController.text != ""
                                  ? _locationController.text
                                  : "Add Location"),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          labelText: 'What\'s on your mind?',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Pallete.accentColor,
                          ),
                          onPressed: () {
                            uploadPost();
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Add Post",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // ignore: dead_code
        isLoading ? const LoaderWidget() : const SizedBox(),
      ],
    );
  }
}
