import 'package:flutter/material.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DisconnectedScreen extends StatefulWidget {
  const DisconnectedScreen({super.key});

  @override
  State<DisconnectedScreen> createState() => _DisconnectedScreenState();
}

class _DisconnectedScreenState extends State<DisconnectedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Column(
            children: [
              SvgPicture.asset(
                "assets/icones/disconnected.svg",
                // ignore: deprecated_member_use
                color: primaryColor,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              const SizedBox(height: 20),
              Text(
                'La connexion a échoué, veuillez réessayer plus tard.',
                style: GoogleFonts.montserrat(
                  color: black,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )),
        ],
      ),
    );
  }
}
