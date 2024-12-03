import 'package:flutter/material.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachNotificationScreen extends StatefulWidget {
  const CoachNotificationScreen({super.key});

  @override
  State<CoachNotificationScreen> createState() =>
      _CoachNotificationScreenState();
}

class _CoachNotificationScreenState extends State<CoachNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Notifications'.toUpperCase(),
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.05,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          bottom: 0,
        ),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: secondaryColorLight,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.024,
                left: MediaQuery.of(context).size.width * 0.0385,
                right: MediaQuery.of(context).size.width * 0.0385,
                bottom: MediaQuery.of(context).size.height * 0.024,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lorem ipsum dolor",
                    style: GoogleFonts.raleway(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.0385,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur",
                    style: GoogleFonts.raleway(
                      color: black,
                      fontWeight: FontWeight.w300,
                      fontSize: MediaQuery.of(context).size.width * 0.0385,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            buildNotificationCard(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            buildNotificationCard(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            buildNotificationCard(context),
          ],
        ),
      ),
    );
  }

  Container buildNotificationCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: secondaryColor,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.024,
        left: MediaQuery.of(context).size.width * 0.0385,
        right: MediaQuery.of(context).size.width * 0.0385,
        bottom: MediaQuery.of(context).size.height * 0.024,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lorem ipsum dolor",
            style: GoogleFonts.raleway(
              color: black,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.0385,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
          Text(
            "Lorem ipsum dolor sit amet, consectetur",
            style: GoogleFonts.raleway(
              color: black,
              fontWeight: FontWeight.w300,
              fontSize: MediaQuery.of(context).size.width * 0.0385,
            ),
          ),
        ],
      ),
    );
  }
}
