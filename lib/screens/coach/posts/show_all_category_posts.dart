import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/post_model.dart';
import 'package:gark_academy/screens/user/posts/post_info.dart';
import 'package:gark_academy/services/date_format.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowAllCategoryPosts extends StatefulWidget {
  final String category;
  final List<Post> postsList;
  const ShowAllCategoryPosts(
      {super.key, required this.category, required this.postsList});

  @override
  State<ShowAllCategoryPosts> createState() => _ShowAllCategoryPostsState();
}

class _ShowAllCategoryPostsState extends State<ShowAllCategoryPosts> {
  late List<Post> categoryPosts;

  @override
  void initState() {
    super.initState();
    categoryPosts = widget.postsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          widget.category,
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryPosts.isEmpty
                ? [
                    const Center(
                      child: Text('Aucun article disponible pour le moment'),
                    )
                  ]
                : categoryPosts
                    .map((post) => buildPostCard(context, post))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildPostCard(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostInfo(post: post),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: NetworkImage(post.imageUrl),
            fit: BoxFit.cover,
            //this filter was replaced by the gradient
            //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        // margin: EdgeInsets.symmetric(
        //     horizontal: MediaQuery.of(context).size.width * 0.025),
        width: double.infinity,
        child: Stack(
          children: [
            // This container is used to create a gradient overlay on the image acting as the filter
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: black.withOpacity(1),
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    black.withOpacity(0.0),
                    black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.057,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: const BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/icones/double_arrow.png",
                      width: MediaQuery.of(context).size.width * 0.04,
                    ),
                  )),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.14,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  //color: black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.052,
                    right: MediaQuery.of(context).size.width * 0.15,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          post.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.montserrat(
                            color: secondaryColor,
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.of(context).size.width * 0.034,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formatDate(post.createdAt),
                            style: GoogleFonts.montserrat(
                              color: secondaryColor,
                              fontWeight: FontWeight.w300,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/icones/share.svg",
                            // ignore: deprecated_member_use
                            color: secondaryColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
