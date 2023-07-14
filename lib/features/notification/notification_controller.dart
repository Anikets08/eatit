import 'package:eatit/features/notification/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider = Provider((ref) => NotificationController(
      notificationRepository: ref.read(notificationRepositoryProvider),
    ));

class NotificationController {
  final NotificationRepository _notificationRepository;

  NotificationController(
      {required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  Future<void> subscribeToNotification(
      String uidUserToSubscribe,
      String uidUserToNotify,
      String tokenToNotify,
      BuildContext context) async {
    final res = await _notificationRepository.subscribeToNotification(
        uidUserToSubscribe, uidUserToNotify, tokenToNotify);
    res.fold(
      (l) => print(l),
      (r) => print(r),
    );
  }

  Future<void> unsubscribeUser(String uid, String subscribedUid, String myToken,
      BuildContext context) async {
    final res = await _notificationRepository.unsubscribeUser(
        uid, subscribedUid, myToken);
    res.fold(
      (l) => print(l),
      (r) => print(r),
    );
  }
}
