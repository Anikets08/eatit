import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:eatit/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider),
    ));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      print("google sign in called");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      late UserModel userModel;
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName!,
          profilePicture: userCredential.user!.photoURL!,
          foodieLevel: 0,
          bookmarks: [],
          avatarName:
              userCredential.user!.displayName.toString().substring(0, 3) +
                  userCredential.user!.uid.substring(0, 3),
          avatarImg: Random().nextInt(12).toString(),
          subscribedTo: [],
        );
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());
      } else {
        DocumentSnapshot documentSnapshot = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        userModel = UserModel.fromJson(
          documentSnapshot.data() as Map<String, dynamic>,
        );
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      print(e.toString());
      return left(e.toString());
    }
  }

  Future<Either<String, String>> signOut() async {
    try {
      await _auth.signOut();
      return right('success');
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(e.toString());
    }
  }
}
