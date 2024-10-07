import 'package:flutter/material.dart';
import 'package:gark_academy/screens/authentification/login_screen.dart';
import 'package:gark_academy/screens/authentification/register_screen.dart';
import 'package:gark_academy/screens/coach/home/coach_notification_screen.dart';
import 'package:gark_academy/screens/user/home/notification_screen.dart';
import 'package:gark_academy/screens/authentification/offline_home_page.dart';
import 'package:gark_academy/screens/user/profile/add_account_screen.dart';
import 'package:gark_academy/widgets/coach/coach_bottom_navigation_bar.dart';
import 'package:gark_academy/widgets/user/bottom_navigation_bar.dart';

class Routes {
  Routes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String userNavbar = '/homeUser';
  static const String coachNavbar = '/homeCoach';
  static const String postInfo = '/post-info';
  static const String addAccount = '/add-account';
  static const String notifcations = '/notifcations';
  static const String coachNotifcations = '/coachNotifcations';
  static const String viewAllMessages = '/viewAllMessages';
  static const String offlineHomePage = '/offlineHomePage';

  static final routes = <String, WidgetBuilder>{
    //general
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    offlineHomePage: (context) => const OfflineHomePage(),
    //user
    userNavbar: (context) => const NavBarWidget(),
    addAccount: (context) => const AddAccountScreen(),
    notifcations: (context) => const NotificationScreen(),
    coachNotifcations: (context) => const CoachNotificationScreen(),
    //coach
    coachNavbar: (context) => const CoachNavBarWidget(),
  };
}
