import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:gark_academy/models/post_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/screens/user/posts/post_info.dart';
import 'package:gark_academy/screens/user/posts/show_all_category_posts.dart';
import 'package:gark_academy/screens/widgets/payment_banner.dart';
import 'package:gark_academy/services/payment_service.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/services/provider/post_provider.dart';
import 'package:gark_academy/services/provider/member_provider.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart'as cs;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PaymentService _paymentService = PaymentService();
  User? user;
  bool isLoading = true;
  String? errorMessage;
  List<Post> carouselPosts = [];
  List<Post> secondPosts = [];
  List<Post> thirdPosts = [];
  String? academyLogo;
  String? bannerColor;

  int maxPosts2 = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
      _getFCMToken();
      _fetchPostData();
      _fetchAcademyLogo();
      checkPaymentStatus();
    });
  }

  void _getFCMToken() async {
    try {
      final notifProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      await notifProvider.getFcmToken();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void checkPaymentStatus() async {
    try {
      await context.read<MemberProvider>().checkPaymentStatus();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _fetchAcademyLogo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      academyLogo = prefs.getString('academyLogo');
    });
  }

  void _fetchPostData() async {
    await Provider.of<PostProvider>(context, listen: false)
        .fetchAdherantPosts();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    setState(() {
      carouselPosts = postProvider.posts
          .where((post) => post.category == 'Football')
          .toList();
      secondPosts = postProvider.posts
          .where((post) => post.category == 'Basketball')
          .toList();
      if (postProvider.posts.length < maxPosts2) {
        setState(() {
          maxPosts2 = postProvider.posts.length;
        });
      }
      thirdPosts = postProvider.posts
          .where((post) =>
              post.category != 'Football' && post.category != 'Basketball')
          .toList();
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final userProvider = Provider.of<MemberProvider>(context, listen: false);
      await userProvider.fetchUser();
      setState(() {
        user = userProvider.user;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: isLoading
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: black,
                    ),
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Text(errorMessage!),
                    )
                  : Column(
                      children: [
                        buildTopPart(context, user!.firstname, user!.photo,
                            user!.lastname),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.048),
                        sectionTitle(context, "Actualité"),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.024),
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

  Widget buildTopPart(
      BuildContext context, String firstname, String? photo, String lastname) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.052,
        right: MediaQuery.of(context).size.width * 0.052,
        top: MediaQuery.of(context).size.height * 0.024,
        bottom: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.054,
                width: MediaQuery.of(context).size.height * 0.054,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: photo ??
                        'https://ui-avatars.com/api/?name=${user?.firstname}+${user?.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=512',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                      color: black,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: black,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.024),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Bonjour, ",
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                      ),
                    ),
                    TextSpan(
                      text: firstname.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.024),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.045,
                width: MediaQuery.of(context).size.height * 0.045,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: academyLogo ??
                        'https://thumbs.dreamstime.com/b/academy-logo-element-vector-illustration-decorative-design-191487693.jpg',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                      color: black,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: black,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.024),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/notifcations");
                },
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      "assets/icones/notification.svg",
                      // ignore: deprecated_member_use
                      color: black,
                      width: MediaQuery.of(context).size.width * 0.06,
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        final unseenCount =
                            notificationProvider.unseenNotificationCount;
                        return unseenCount > 0
                            ? Positioned(
                                top: 0,
                                right: 0,
                                child: Stack(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.018,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.018,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unseenCount',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox
                                .shrink(); //if no unseen notifications
                      },
                    ),
                  ],
                ),
              ),
            ],
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
          // viewButton(context, title),
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

  Widget secondSection(BuildContext context) {
    if (secondPosts.isEmpty) {
      return const Center(
        child: Text('Aucun article disponible pour le moment'),
      );
    }

    final int postsCount = secondPosts.length;
    final int displayedPostsCount =
        (postsCount < maxPosts2) ? postsCount : maxPosts2;
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.052,
        right: MediaQuery.of(context).size.width * 0.052,
        top: 0,
        bottom: 0,
      ),
      child: Column(
        children: [
          for (int i = 0; i < displayedPostsCount; i++)
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
    return Bounceable(
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
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: black,
                    ),
                  ),
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
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: black,
                  ),
                ),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.36,
                      child: Text(
                        post.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                        ),
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
