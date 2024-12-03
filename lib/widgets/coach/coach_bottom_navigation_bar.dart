import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/screens/coach/discussion/coach_view_all_discussions_screen.dart';
import 'package:gark_academy/screens/coach/events/coach_events_screen.dart';
import 'package:gark_academy/screens/coach/home/coach_home_page.dart';
import 'package:gark_academy/screens/coach/profile/coach_profile_screen.dart';
import 'package:gark_academy/utils/colors.dart';

class CoachNavBarWidget extends StatefulWidget {
  const CoachNavBarWidget({super.key});

  @override
  State<CoachNavBarWidget> createState() => _CoachNavBarWidgetState();
}

class _CoachNavBarWidgetState extends State<CoachNavBarWidget> {
  int index = 0;

  final screens = [
    const CoachHomePage(),
    const CoachEventsScreen(),
    const CoachViewAllDiscussionsScreen(),
    const CoachProfileScreen(),
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
