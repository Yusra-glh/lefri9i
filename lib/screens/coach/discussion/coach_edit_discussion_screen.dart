import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachEditDiscussionScreen extends StatefulWidget {
  const CoachEditDiscussionScreen({super.key});

  @override
  State<CoachEditDiscussionScreen> createState() =>
      _CoachEditDiscussionScreenState();
}

class _CoachEditDiscussionScreenState extends State<CoachEditDiscussionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier le groupe',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
          softWrap: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.height * 0.024,
                ),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.024,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: secondaryColorLight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nom du groupe",
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.0385,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.024),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Groupe ABC",
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.036,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Bounceable(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) {
                                //     return const CoachUserEvaluationScreen();
                                //   }),
                                // );
                              },
                              child: SvgPicture.asset(
                                "assets/icones/Edit.svg",
                                // ignore: deprecated_member_use
                                color: black,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.024,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.height * 0.024,
                ),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.024,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: secondaryColorLight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Membres",
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.0385,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.024),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/person1.jpg",
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              "Lorem ipsum",
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.036,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Bounceable(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) {
                                //     return const CoachUserEvaluationScreen();
                                //   }),
                                // );
                              },
                              child: SvgPicture.asset(
                                "assets/icones/delete.svg",
                                // ignore: deprecated_member_use
                                color: black,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.024),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/person2.jpg",
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              "Lorem ipsum",
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.036,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: SvgPicture.asset(
                                "assets/icones/delete.svg",
                                // ignore: deprecated_member_use
                                color: black,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.024),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/person1.jpg",
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              "Lorem ipsum",
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.036,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: SvgPicture.asset(
                                "assets/icones/delete.svg",
                                // ignore: deprecated_member_use
                                color: black,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.024),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/profile.jpg",
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              "Lorem ipsum",
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.036,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: SvgPicture.asset(
                                "assets/icones/delete.svg",
                                // ignore: deprecated_member_use
                                color: black,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
