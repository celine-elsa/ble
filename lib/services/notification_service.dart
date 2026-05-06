import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<String?> initFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Permission (Android дээр ихэвчлэн OK, iOS-д заавал)
    await messaging.requestPermission();

    // Token авах
    final token = await messaging.getToken();

    print("🔥 FCM TOKEN: $token");

    return token;
  }
}