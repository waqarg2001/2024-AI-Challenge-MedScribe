import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeNotifications() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Basic notifications',
          channelShowBadge: true,
          vibrationPattern: highVibrationPattern,
          importance: NotificationImportance.High,
        ),
      ],
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> initNotifications() async {
    initializeNotifications();
    var prefs = await SharedPreferences.getInstance();
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.subscribeToTopic('all');
    var token = await _firebaseMessaging.getToken();
    await prefs.setString('fcmToken', token!);
    print('Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleBackgroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleBackgroundMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

@pragma('vm:entry-point')
Future<dynamic> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'high_importance_channel',
      title: message.notification?.title,
      body: message.notification?.body,
      payload: message.data.cast<String, String?>(),
    ),
  );
}
