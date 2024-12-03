import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PDFViewerFromAsset extends StatelessWidget {
  PDFViewerFromAsset({super.key, required this.pdfAssetPath});
  final String pdfAssetPath;
  final Completer<PDFViewController> _pdfViewController =
      Completer<PDFViewController>();
  final StreamController<String> _pageCountController =
      StreamController<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Les Conditions d'Utilisation",
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * 0.042,
          ),
        ),
      ),
      body: PDF(
        nightMode: false,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageSnap: false,
        // fitEachPage: true,
        // fitPolicy: FitPolicy.WIDTH,
        pageFling: true,
        onPageChanged: (int? current, int? total) =>
            _pageCountController.add('${current! + 1} - $total'),
        onViewCreated: (PDFViewController pdfViewController) async {
          _pdfViewController.complete(pdfViewController);
          final int currentPage = await pdfViewController.getCurrentPage() ?? 0;
          final int? pageCount = await pdfViewController.getPageCount();
          _pageCountController.add('${currentPage + 1} - $pageCount');
        },
      ).fromAsset(
        pdfAssetPath,
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
