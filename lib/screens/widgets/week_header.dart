import 'package:flutter/material.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WeekHeader extends StatelessWidget {
  const WeekHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM']
          .map((day) => Text(
                day,
                style: GoogleFonts.montserrat(
                  color: primaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: MediaQuery.of(context).size.width * 0.0385,
                ),
              ))
          .toList(),
    );
  }
}
