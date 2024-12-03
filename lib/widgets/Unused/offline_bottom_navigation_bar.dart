import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/screens/user/home/Unused/login_required_page.dart';
import 'package:gark_academy/screens/authentification/offline_home_page.dart';
import 'package:gark_academy/utils/colors.dart';

class OfflineBottomNavigationBar extends StatefulWidget {
  const OfflineBottomNavigationBar({super.key});

  @override
  State<OfflineBottomNavigationBar> createState() =>
      _OfflineBottomNavigationBarState();
}

class _OfflineBottomNavigationBarState
    extends State<OfflineBottomNavigationBar> {
  int index = 0;

  final screens = [
    const OfflineHomePage(),
    const LoginRequiredPage(),
    const LoginRequiredPage(),
    const LoginRequiredPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(
        Icons.home,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
      Icon(
        Icons.calendar_today_outlined,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
      Icon(
        Icons.chat_bubble_outline,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
      Icon(
        Icons.person_2_outlined,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
    ];
    return Scaffold(
      extendBody: true,
      body: screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: secondaryColorLight),
        ),
        child: CurvedNavigationBar(
          onTap: (index) => setState(() {
            this.index = index;
          }),
          //first icon of the navigation bar
          index: index,
          //items of the navigation bar
          items: items,
          height: MediaQuery.of(context).size.height * 0.072,
          backgroundColor: Colors.transparent,
          //color of the navigation bar
          color: black,
          //color of the navigation bar items
          buttonBackgroundColor: primaryColor,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 400),
        ),
      ),
    );
  }
}
