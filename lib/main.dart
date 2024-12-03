import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:gark_academy/screens/authentification/disconnected_screen.dart';
import 'package:gark_academy/screens/authentification/login_screen.dart';
import 'package:gark_academy/services/firebase_service.dart';
import 'package:gark_academy/services/provider/event_provider.dart';
import 'package:gark_academy/services/provider/coach_provider.dart';
import 'package:gark_academy/services/provider/message_provider.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/services/provider/post_provider.dart';
import 'package:gark_academy/services/provider/training_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';
import 'services/auth_service.dart';
import 'services/provider/member_provider.dart';
import 'utils/routes.dart';

final AuthService _authService = AuthService();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService().setupInteractedMessage();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (context) => CoachProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
        ChangeNotifierProvider(create: (context) => TrainingProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gark Academy',
        locale: const Locale('fr'),
        theme: ThemeData(
          colorScheme: const ColorScheme.light(primary: Colors.green),
          primarySwatch: Colors.grey,
          fontFamily: GoogleFonts.montserrat().fontFamily ?? 'Montserrat',
          iconTheme: const IconThemeData(
            color: Colors.green,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: UpgradeAlert(
            dialogStyle: Platform.isIOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            showIgnore: false,
            showLater: false,
            child: const InitializerScreen()),
        routes: Routes.routes,
        navigatorObservers: [routeObserver],
      ),
    );
  }
}

class InitializerScreen extends StatelessWidget {
  const InitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedInUser(),
      builder: (context, snapshot) {
        log("---------------- here InitializerScreen");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
          // Use WidgetsBinding.instance.addPostFrameCallback to ensure the Navigator
          // pushReplacement is called after the build is completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          });
        } else if (snapshot.hasData && snapshot.data!) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? role = prefs.getString('userRole');

            // Connect to WebSocket with the user's email
            String? email = prefs.getString('userEmail');
            if (email != null) {
              Provider.of<NotificationProvider>(context, listen: false)
                  .connectWebSocket(email);
            }
            if (role == "ADHERENT") {
              Navigator.pushReplacementNamed(context, '/homeUser');
            } else if (role == "ENTRAINEUR") {
              Navigator.pushReplacementNamed(context, '/homeCoach');
            }
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}

Future<bool> isLoggedInUser() async {
  final accessToken = await _authService.getAccessTokenFromStorage();

  if (accessToken != null) {
    bool isValidToken = await _authService.checkAccessToken(accessToken);

    if (isValidToken) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('userRole');

      if (role == "ADHERENT" || role == "ENTRAINEUR") {
        return true;
      }
    }
  }
  return false;
}
