import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/core/constants/constants.dart';
import 'package:eatit/core/providers/firebase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

class NotificationModel {
  final String uid;
  final String token;

  NotificationModel({required this.uid, required this.token});
}

final notificationRepositoryProvider = Provider((ref) => NotificationRepository(
      firestore: ref.read(firestoreProvider),
    ));

class NotificationRepository {
  final FirebaseFirestore _firestore;
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<String, String>> subscribeToNotification(
    String uidUserToSubscribe,
    String uidUserToNotify,
    String tokenToNotify,
  ) async {
    try {
      await http
          .post(
        Uri.parse("${Constants.baseUrl}${Constants.SUB_PATH}"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {"token": tokenToNotify, "topic": uidUserToSubscribe},
        ),
      )
          .then((value) async {
        print(value.body);
      });
      // subscribe to topic which is uidUserToSubscribe and token is tokenToNotify
      await _firestore.collection("users").doc(uidUserToNotify).update({
        "subscribedTo": FieldValue.arrayUnion([
          {uidUserToSubscribe: tokenToNotify}
        ]),
      });

      return right("success");
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, String>> unsubscribeUser(
      String uid, String subscribedUid, String myToken) async {
    try {
      await http.post(
        Uri.parse("${Constants.baseUrl}${Constants.UNSUB_PATH}"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {"token": myToken, "topic": subscribedUid},
        ),
      );

      await _firestore.collection("users").doc(uid).update({
        // "subscribedTo": FieldValue.arrayRemove([subscribedUid]),
        // remove a object from array
        "subscribedTo": FieldValue.arrayRemove([
          {subscribedUid: myToken}
        ]),
      });
      // unsubscribe to topic which is subscribedUid and token is myToken
      return right("success");
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      return left(e.toString());
    }
  }
}
