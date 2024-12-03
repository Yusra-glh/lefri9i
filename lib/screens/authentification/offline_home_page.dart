import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/models/post_model.dart';
import 'package:gark_academy/screens/user/posts/post_info.dart';
import 'package:gark_academy/screens/user/posts/show_all_category_posts.dart';
import 'package:gark_academy/services/date_format.dart';
import 'package:gark_academy/services/post_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter_svg/flutter_svg.dart';

class OfflineHomePage extends StatefulWidget {
  const OfflineHomePage({super.key});

  @override
  State<OfflineHomePage> createState() => _OfflineHomePageState();
}

class _OfflineHomePageState extends State<OfflineHomePage> {
  List<Post> carouselPosts = [];
  List<Post> secondPosts = [];
  List<Post> thirdPosts = [];
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    getInfos();
  }

  void getInfos() async {
    try {
      List<Post> posts = await _postService.getPublicPosts();
      print('Fetched Posts: $posts');
      setState(() {
        carouselPosts =
            posts.where((post) => post.category == 'Football').toList();
        secondPosts =
            posts.where((post) => post.category == 'Basketball').toList();
        thirdPosts = posts
            .where((post) =>
                post.category != 'Football' && post.category != 'Basketball')
            .toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTopPart(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.048),
              sectionTitle(context, "Actualité"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              firstSection(context),
              SizedBox(
                            height: MediaQuery.of(context).size.height * 0.048),
                        sectionTitle(context, "Découvrir"),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.024),
                        actualitePosts(context),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        // SizedBox(
                        //     height: MediaQuery.of(context).size.height * 0.048),
                        // sectionTitle(context, "Basketball"),
                        // SizedBox(
                        //     height: MediaQuery.of(context).size.height * 0.024),
                        // secondSection(context),
                        // SizedBox(
                        //     height: MediaQuery.of(context).size.height * 0.048),
                        // sectionTitle(context, "Autres"),
                        // SizedBox(
                        //     height: MediaQuery.of(context).size.height * 0.024),
                        // thirdSection(context),
                        // SizedBox(
                        //     height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopPart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.052,
        right: MediaQuery.of(context).size.width * 0.052,
        top: MediaQuery.of(context).size.height * 0.024,
        bottom: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Container(
              // margin: EdgeInsets.only(
              //     right: MediaQuery.of(context).size.width * 0.045),
              // padding: EdgeInsets.all(
              //   MediaQuery.of(context).size.height * 0.018,
              //),
              child: SvgPicture.asset(
                "assets/icones/login.svg",
                // ignore: deprecated_member_use
                color: black,
                width: MediaQuery.of(context).size.width * 0.0905,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.052,
        right: MediaQuery.of(context).size.width * 0.052,
        top: 0,
        bottom: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              color: black,
              fontWeight: FontWeight.w800,
              fontSize: MediaQuery.of(context).size.width * 0.042,
            ),
          ),
          //viewButton(context, title),
        ],
      ),
    );
  }

  Widget viewButton(BuildContext context, String title) {
    return MaterialButton(
      onPressed: () {
        if (title == "Football") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowAllCategoryPosts(
                category: title,
                postsList: carouselPosts,
              ),
            ),
          );
        } else if (title == "Basketball") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowAllCategoryPosts(
                category: title,
                postsList: secondPosts,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowAllCategoryPosts(
                category: title,
                postsList: thirdPosts,
              ),
            ),
          );
        }
      },
      // Style and other button properties
      color: black,
      padding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: MediaQuery.of(context).size.width * 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Text(
        "Voir tout",
        style: GoogleFonts.montserrat(
          color: secondaryColor,
          fontWeight: FontWeight.w400,
          fontSize: MediaQuery.of(context).size.width * 0.034,
        ),
      ),
    );
  }
 Widget actualitePosts(BuildContext context) {
    return Column(
      children: carouselPosts.map((post) {
        return firstSectionListTile(context, post);
      }).toList(),
    );
  }
  
  Widget firstSectionListTile(BuildContext context, Post carouselPost) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostInfo(post: carouselPost),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.025),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              carouselPost.imageUrl,
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.3,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            carouselPost.title.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: MediaQuery.of(context).size.width * 0.042,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                carouselPost.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: MediaQuery.of(context).size.width * 0.034,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(carouselPost.createdAt),
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: MediaQuery.of(context).size.width * 0.0315,
                    ),
                  ),
                  // SvgPicture.asset(
                  //   "assets/icones/share.svg",
                  //   color: Colors.black,
                  // ),
                ],
              ),
            ],
          ),
          trailing: Container(
            height: MediaQuery.of(context).size.height * 0.057,
            width: MediaQuery.of(context).size.width * 0.09,
            decoration: const BoxDecoration(
              color: white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Center(
              child: Image.asset(
                "assets/icones/double_arrow.png",
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget firstSection(BuildContext context) {
    if (carouselPosts.isEmpty) {
      return const Center(
        child: Text('Aucun article disponible pour le moment'),
      );
    }
    return cs.CarouselSlider.builder(
      options: cs.CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.288,
        autoPlay: true,
        reverse: false,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
        pageSnapping: false,
        enlargeCenterPage: true,
        enlargeStrategy: cs.CenterPageEnlargeStrategy.height,
        enlargeFactor: .4,
      ),
      itemCount: carouselPosts.length,
      itemBuilder: (context, index, realIndex) {
        final carouselPost = carouselPosts[index];
        return firstSectionCard(context, carouselPost);
      },
    );
  }

  Widget firstSectionCard(BuildContext context, Post carouselPost) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostInfo(post: carouselPost),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: NetworkImage(carouselPost.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.025),
        width: double.infinity,
        child: Stack(
          children: [
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
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                //height: MediaQuery.of(context).size.height * 0.14,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.052,
                    right: MediaQuery.of(context).size.width * 0.3,
                    bottom: MediaQuery.of(context).size.width * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        carouselPost.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          carouselPost.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
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
                            formatDate(carouselPost.createdAt),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/icones/share.svg",
                            // ignore: deprecated_member_use
                            color: Colors.white,
                          ),
                        ],
                      ),
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

  Widget secondSection(BuildContext context) {
    if (secondPosts.isEmpty) {
      return const Center(
        child: Text('Aucun article disponible pour le moment'),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.052,
        right: MediaQuery.of(context).size.width * 0.052,
        top: 0,
        bottom: 0,
      ),
      child: Column(
        children: [
          for (int i = 0; i < 2; i++)
            Column(
              children: [
                secondSectionCard(context, secondPosts[i]),
                if (i != secondPosts.length - 1)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              ],
            ),
        ],
      ),
    );
  }

  Widget secondSectionCard(BuildContext context, Post post) {
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
        decoration: BoxDecoration(
          color: secondaryColorLight,
          borderRadius: BorderRadius.circular(15),
        ),
        height: MediaQuery.of(context).size.height * 0.15,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.03,
                  right: MediaQuery.of(context).size.width * 0.03,
                  top: MediaQuery.of(context).size.height * 0.01,
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
                        color: black,
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width * 0.0385,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        post.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.029,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          formatDate(post.createdAt),
                          style: GoogleFonts.montserrat(
                            color: black.withOpacity(.5),
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.of(context).size.width * 0.029,
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/icones/share.svg",
                          // ignore: deprecated_member_use
                          color: black,
                          width: MediaQuery.of(context).size.width * 0.055,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget thirdSection(BuildContext context) {
    if (thirdPosts.isEmpty) {
      return const Center(
        child: Text('Aucun article disponible pour le moment'),
      );
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: ListView.separated(
        itemCount: thirdPosts.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: MediaQuery.of(context).size.width * 0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final thirdPost = thirdPosts[index];
          final isLast = index == thirdPosts.length - 1;
          return thirdSectionCard(context, thirdPost, isLast);
        },
      ),
    );
  }

  Widget thirdSectionCard(BuildContext context, Post post, bool isLast) {
    final rightMargin =
        isLast ? MediaQuery.of(context).size.width * 0.052 : 0.0;
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
          left: MediaQuery.of(context).size.width * 0.052,
          right: rightMargin,
          top: 0,
          bottom: 0,
        ),
        width: MediaQuery.of(context).size.height * 0.2,
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
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
              bottom: 0,
              left: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.048,
                  right: MediaQuery.of(context).size.width * 0.048,
                  top: 0,
                  bottom: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: secondaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      post.createdAt,
                      style: GoogleFonts.montserrat(
                        color: secondaryColor,
                        fontWeight: FontWeight.w300,
                        fontSize: MediaQuery.of(context).size.width * 0.026,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
