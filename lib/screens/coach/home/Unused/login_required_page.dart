import 'package:flutter/material.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginRequiredPage extends StatefulWidget {
  const LoginRequiredPage({super.key});

  @override
  State<LoginRequiredPage> createState() => _LoginRequiredPageState();
}

class _LoginRequiredPageState extends State<LoginRequiredPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/needLoginIllustration.png"),
            SizedBox(height: MediaQuery.of(context).size.height * 0.048),
            Text(
              "Vous devez être connecté pour\n accéder à cette section ",
              style: GoogleFonts.montserrat(
                color: black,
                fontWeight: FontWeight.w400,
                fontSize: MediaQuery.of(context).size.width * 0.0385,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.072),
            MaterialButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              height: MediaQuery.of(context).size.height * 0.054,
              minWidth: MediaQuery.of(context).size.width * 0.65,
              color: primaryColor,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.012,
                horizontal: MediaQuery.of(context).size.width * 0.13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Text(
                "Connecter".toUpperCase(),
                style: GoogleFonts.montserrat(
                  color: white,
                  fontWeight: FontWeight.w700,
                  fontSize: MediaQuery.of(context).size.width * 0.047,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
