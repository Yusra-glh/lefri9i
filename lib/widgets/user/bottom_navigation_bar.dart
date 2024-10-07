import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/screens/user/discussion/view_all_discussions_screen.dart';
import 'package:gark_academy/screens/user/events/events_screen.dart';
import 'package:gark_academy/screens/user/home/home_page.dart';
import 'package:gark_academy/screens/user/profile/profile_screen.dart';
import 'package:gark_academy/screens/widgets/Payment_banner.dart';
import 'package:gark_academy/services/provider/member_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  int index = 0;

  final screens = [
    const HomePage(),
    const EventsScreen(),
    const ViewAllDiscussionsScreen(),
    const ProfileScreen(),
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
      appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: context.watch<MemberProvider>().paymentStatus != null
              ? MediaQuery.of(context).size.height * 0.05
              : 0,
          flexibleSpace: const PaymentBanner()),
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
