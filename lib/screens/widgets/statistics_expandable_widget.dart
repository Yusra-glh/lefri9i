import 'package:flutter/material.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableSection extends StatefulWidget {
  final String title;
  final bool isExpanded;
  const ExpandableSection({
    super.key,
    required this.title,
    required this.isExpanded,
  });
  @override
  // ignore: library_private_types_in_public_api
  _ExpandableSectionState createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: secondaryColor,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.012,
        left: MediaQuery.of(context).size.width * 0.052,
        right: MediaQuery.of(context).size.width * 0.052,
        bottom: MediaQuery.of(context).size.height * 0.018,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _title.toUpperCase(),
                style: GoogleFonts.montserrat(
                  color: black,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.042,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.052,
                    MediaQuery.of(context).size.height * 0.024,
                  ),
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.005),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  overlayColor: grey.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? "–" : "+",
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: _isExpanded ? FontWeight.w700 : FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.042,
                  ),
                ),
              ),
            ],
          ),
          if (_isExpanded)
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                buildMentalityRow("Attitude", 0.9, primaryColor),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                buildMentalityRow("Leadership", 0.2, darkRed),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                buildMentalityRow("Intensité", 0.7, primaryColor),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                buildMentalityRow("Leadership", 0.4, yellow),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: grey.withOpacity(0.5),
                    ),
                    onPressed: () {
                      buildBottomSheetPopup(context);
                    },
                    child: Text(
                      "voir plus",
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.036,
                        decoration: TextDecoration.underline,
                        decorationColor: black,
                      ),
                    ),
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  Future<dynamic> buildBottomSheetPopup(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(25),
          ),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.012,
              left: MediaQuery.of(context).size.width * 0.052,
              right: MediaQuery.of(context).size.width * 0.052,
              bottom: MediaQuery.of(context).size.height * 0.018,
            ),
            child: Column(
              children: [
                Divider(
                  thickness: 3,
                  color: primaryColor,
                  indent: MediaQuery.of(context).size.width * 0.38,
                  endIndent: MediaQuery.of(context).size.width * 0.38,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.012,
                  ),
                  child: Text(
                    _title.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2825,
                        child: Text(
                          "Attitude : ".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0315,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w400,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0295,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Text(
                        "(bien)",
                        style: GoogleFonts.montserrat(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.0295,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2825,
                        child: Text(
                          "Leadership : ".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0315,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Lorem ipsum dolor sit amet",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w400,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0295,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Text(
                        "(faible)",
                        style: GoogleFonts.montserrat(
                          color: red,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.0295,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2825,
                        child: Text(
                          "Intensité : ".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0315,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Lorem ipsum dolor sit amet",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w400,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0295,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Text(
                        "(bien)",
                        style: GoogleFonts.montserrat(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.0295,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2825,
                        child: Text(
                          "Assiduité : ".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0315,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Lorem ipsum dolor sit amet",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w400,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0295,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Text(
                        "(moyen)",
                        style: GoogleFonts.montserrat(
                          color: yellow,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.0295,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMentalityRow(String title, double value, Color color) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.024,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(title),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              minHeight: 7,
              value: value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ],
      ),
    );
  }
}
