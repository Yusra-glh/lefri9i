import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gark_academy/services/provider/member_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaymentBanner extends StatefulWidget {
  const PaymentBanner({super.key});

  @override
  State<PaymentBanner> createState() => _PaymentBannerState();
}

class _PaymentBannerState extends State<PaymentBanner> {
  @override
  Widget build(BuildContext context) {
    final bannerColor = context.watch<MemberProvider>().paymentStatus;
    log("bannerColor--------------------- $bannerColor");
    return SizedBox(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.052,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        color: bannerColor == 'red' || bannerColor == 'superRed'
            ? Colors.red
            : bannerColor == 'orange'
                ? Colors.orange
                : Colors.green,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            bannerColor == 'red'
                ? 'Votre abonnement va expirer'
                : bannerColor == 'superRed'
                    ? 'Votre abonnement a expiré'
                    : bannerColor == 'orange'
                        ? 'Votre abonnement expirera bientôt'
                        : 'Votre abonnement est payé',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.038,
            ),
          ),
        ),
      ),
    );
  }
}
