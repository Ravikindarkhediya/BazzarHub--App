import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../presentation/services/api_service.dart';
import '../presentation/services/models/user/user_model.dart';

class FirebaseManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    try {
      NotificationSettings notificationSettings =
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        criticalAlert: true,
        carPlay: false,
        provisional: false,
      );

      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        print('User granted permission');

        try {
          UserModel? userModel = await SessionManager().getUser();
          if (userModel != null) {
            // if (userModel.allowPushNotification) {
            //   subscribeToTopic("sendtoall");
            //   subscribeToTopic(Platform.isIOS ? "sendtoios" : "sendtoandroid");
            // } else {
            //   unsubscribeFromTopic("sendtoall");
            //   unsubscribeFromTopic(Platform.isIOS ? "sendtoios" : "sendtoandroid");
            // }
          }
        } catch (e) {
          print('Error loading user model: $e');
        }

        try {
          if (Platform.isIOS) {
            final String? apnsToken = await _firebaseMessaging.getAPNSToken();
            print('APNs Token: $apnsToken');
          }
        } catch (e) {
          print('Error getting APNs token: $e');
        }

        try {
          var initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
          var initializationSettingsIOS = const DarwinInitializationSettings();
          var initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse:
                (NotificationResponse notificationResponse) {
              try {
                if (notificationResponse.payload != null) {
                  print("NOTIFICATION PAYLOAD ============ ${notificationResponse.payload}");
                  _handleNotificationClickPayload(notificationResponse.payload!);
                }
              } catch (e) {
                print('Error handling notification response: $e');
              }
            },
          );
        } catch (e) {
          print('Error initializing local notifications: $e');
        }

        await _getFCMToken();

        _setForegroundMessageHandler();

        try {
          FirebaseMessaging.instance
              .getInitialMessage()
              .then((RemoteMessage? message) {
            if (message != null) {
              if (message.data.isNotEmpty) {
                print("Data payload: ${message.data}");
              } else {
                print("No data payload received.");
              }
            }
          }).catchError((error) {
            print('Error getting initial message: $error');
          });
        } catch (e) {
          print('Error setting up initial message: $e');
        }

        try {
          FirebaseMessaging.onMessageOpenedApp.listen(
                (RemoteMessage message) {
              if (message.data.isNotEmpty) {
                print("Data payload: ${message.data}");
                _handleNotificationClickPayload(jsonEncode(message.data));
              } else {
                print("No data payload received.");
              }
            },
            onError: (error) {
              print('Error on message opened app: $error');
            },
          );
        } catch (e) {
          print('Error setting up message opened app listener: $e');
        }
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error in initNotification: $e');
    }
  }

  Future<void> _getFCMToken() async {
    try {
      String? fcmToken;
      int retries = 3;

      while (fcmToken == null && retries > 0) {
        try {
          fcmToken = await _firebaseMessaging.getToken().timeout(
            const Duration(seconds: 10),
            onTimeout: () => null,
          );

          if (fcmToken != null) {
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
            break;
          }
        } on FirebaseException catch (e) {
          print('Firebase error getting token: ${e.message}');
          if (e.code == 'permission-denied') break;
        } on TimeoutException catch (e) {
          print('Timeout getting token: $e');
        } catch (e) {
          print('Error getting token: $e');
        }

        retries--;
        if (retries > 0 && fcmToken == null) {
          await Future.delayed(Duration(seconds: 2));
        }
      }

      if (fcmToken == null) {
        print('Failed to get FCM token after retries');
      }
    } catch (e) {
      print('Error in _getFCMToken: $e');
    }
  }

  void _setForegroundMessageHandler() {
    try {
      FirebaseMessaging.onMessage.listen(
            (RemoteMessage message) async {
          try {
            await _showNotification(message);
          } catch (e) {
            print('Error showing notification: $e');
          }
        },
        onError: (error) {
          print('Error in foreground message handler: $error');
        },
      );
    } catch (e) {
      print('Error setting foreground message handler: $e');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    try {
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
        0,
        message.notification?.title,
        message.notification?.body,
        platformDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      print('Error in _showNotification: $e');
    }
  }

  static Future<void> _handleNotificationClickPayload(String payload) async {
    try {
      print(payload);
      if (payload.isEmpty) return;
      final data = jsonDecode(payload);

      if (data.containsKey('msg')) {
        final msgData = data['msg'];
        if (msgData != null && msgData.isNotEmpty) {}
      }
    } catch (e) {
      print('Error handling notification payload: $e');
    }
  }

  void subscribeToTopic(String topic) {
    try {
      print("Subscribed to topic! - $topic");
      FirebaseMessaging.instance.subscribeToTopic(topic).then((_) {
        print("Subscribed to topic! - $topic");
      }).catchError((error) {
        print("Failed to subscribe: $error");
      });
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  void unsubscribeFromTopic(String topic) {
    try {
      FirebaseMessaging.instance.unsubscribeFromTopic(topic).then((_) {
        print("Unsubscribed from topic!");
      }).catchError((error) {
        print("Failed to unsubscribe: $error");
      });
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
