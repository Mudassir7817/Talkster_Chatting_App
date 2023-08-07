import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'screens/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
  ).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This function initializes Firebase and shows a loading screen until it's done.
  Future<FirebaseApp> _initializeFireBase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For showing messages',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats',
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    );
    return Firebase.app();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFireBase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen while Firebase is initializing
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle initialization errors gracefully
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Error initializing Firebase'),
              ),
            ),
          );
        } else {
          // Firebase is initialized, return the main app
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Talkster',
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                color: Color.fromARGB(255, 130, 130, 177),
                centerTitle: true,
              ),
            ),
            home: SplashScreen(),
          );
        }
      },
    );
  }
}
