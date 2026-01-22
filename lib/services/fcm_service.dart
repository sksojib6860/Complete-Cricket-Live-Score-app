import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FcmService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      carPlay: true,
      providesAppNotificationSettings: true,
      provisional: true,
      sound: true,
    );

    //------------------ when app opened -----------------

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(message.notification?.title);
      debugPrint(message.notification?.body);
      debugPrint(message.data as String?);
    });

    //----------------- when opened in background not in View---------------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(message.notification?.title);
      debugPrint(message.notification?.body);
      debugPrint(message.data as String?);
    });

    //----------------- when terminated terminated ------------------
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotification);
  }
}

// -------------------- background notification handler----------------

Future<void> onBackgroundNotification(RemoteMessage message) async {
  debugPrint(message.notification?.title);
  debugPrint(message.notification?.body);
  debugPrint(message.data as String?);
}
