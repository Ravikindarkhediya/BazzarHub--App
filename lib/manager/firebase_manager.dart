import 'dart:convert';

import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../presentation/services/api_service.dart';
import '../presentation/services/models/user/user_model.dart';


class FirebaseManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    NotificationSettings notificationSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      criticalAlert: true, // For high-priority alerts
      carPlay: false,
      provisional: false,  // Ensure this is false to show banners & sounds
    );

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      UserModel? userModel = await SessionManager().getUser();
      if(userModel != null) {
        // if (userModel.allowPushNotification) {
        //   subscribeToTopic("sendtoall");
        //   subscribeToTopic(Platform.isIOS ? "sendtoios" : "sendtoandroid");
        // } else {
        //   unsubscribeFromTopic("sendtoall");
        //   unsubscribeFromTopic(Platform.isIOS ? "sendtoios" : "sendtoandroid");
        // }
      }

      final String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print('APNs Token: $apnsToken');

      // Initialize local notifications
      var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = const DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          if (notificationResponse.payload != null) {
            print("NOTIFICATION PAYLOAD ============ ${notificationResponse.payload}");
            _handleNotificationClickPayload(notificationResponse.payload!);
          }
        },
      );

      await _getFCMToken();

      _setForegroundMessageHandler();

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          if (message.data.isNotEmpty) {
            print("Data payload: ${message.data}");
          } else {
            print("No data payload received.");
          }
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data.isNotEmpty) {
          print("Data payload: ${message.data}");
          _handleNotificationClickPayload(jsonEncode(message.data));
        } else {
          print("No data payload received.");
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _getFCMToken() async {
    final String? fcmToken = await _firebaseMessaging.getToken();
    var apiClient = await getApiClient();
    print("FCM TOKEN ========= $fcmToken");
    // var params = {
    //   "token": fcmToken,
    //   "deviceId": await Utils.getDeviceId(),
    //   "platform": Platform.isIOS ? "ios" : "android",
    //   "provider": "firebase",
    // };
    // try {
    //   var response = await apiClient.requestRegisterFCMToken(params);
    //   if (response != null) {
    //
    //   }
    // } on DioError catch (e) {
    //   print(e);
    // } catch (error) {
    //   print(error);
    // }
  }

  void _setForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showNotification(message);
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    print('Received a foreground message: ${message.notification?.title}');
    var androidDetails = const AndroidNotificationDetails(
      'Default',
      'Default channel',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var iosDetails = const DarwinNotificationDetails();

    var platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    print('payload ${message.data}');
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> _handleNotificationClickPayload(String payload) async {
    print(payload);
    if (payload.isEmpty) return;
    final data = jsonDecode(payload);

    if (data.containsKey('msg')) {
      final msgData = data['msg'];
      if (msgData != null && msgData.isNotEmpty) {}
    }
  }



  void subscribeToTopic(String topic) {
    print("Subscribed to topic! - $topic");
    FirebaseMessaging.instance.subscribeToTopic(topic).then((_) {
      print("Subscribed to topic! - $topic");
    }).catchError((error) {
      print("Failed to subscribe: $error");
    });
  }

  void unsubscribeFromTopic(String topic) {
    FirebaseMessaging.instance.unsubscribeFromTopic(topic).then((_) {
      print("Unsubscribed from topic!");
    }).catchError((error) {
      print("Failed to unsubscribe: $error");
    });
  }

}
