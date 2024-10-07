import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/post_model.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PostInfo extends StatelessWidget {
  final Post post;
  const PostInfo({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: CachedNetworkImage(
              imageUrl: post.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: black,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.045,
                    ),
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        "assets/icones/arrow-back.svg",
                        // ignore: deprecated_member_use
                        color: white,
                        width: MediaQuery.of(context).size.width * 0.055,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.045,
                    ),
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: GestureDetector(
                      child: SvgPicture.asset(
                        "assets/icones/share.svg",
                        // ignore: deprecated_member_use
                        color: white,
                        width: MediaQuery.of(context).size.width * 0.055,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.3,
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.024,
              left: MediaQuery.of(context).size.width * 0.078,
              right: MediaQuery.of(context).size.width * 0.078,
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.024),
                  Text(
                    //post title
                    post.title,
                    style: GoogleFonts.montserrat(
                      color: black,
                      fontWeight: FontWeight.w800,
                      fontSize: MediaQuery.of(context).size.width * 0.052,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                  Row(
                    children: [
                      Text(
                        //Academy name
                        "Academie:",
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w800,
                          fontSize: MediaQuery.of(context).size.width * 0.048,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.024),
                      Text(
                        post.academy!.nom,
                        style: GoogleFonts.montserrat(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: MediaQuery.of(context).size.width * 0.048,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                  //post body
                  Text(
                    post.body,
                    style: GoogleFonts.montserrat(
                      color: black,
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.width * 0.0385,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.096),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
