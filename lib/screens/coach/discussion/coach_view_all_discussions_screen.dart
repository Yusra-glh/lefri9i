import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/message_model.dart';
import 'package:gark_academy/screens/coach/discussion/coach_create_discussion_screen.dart';
import 'package:gark_academy/screens/coach/discussion/coach_discussion_screen.dart';
import 'package:gark_academy/services/provider/message_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoachViewAllDiscussionsScreen extends StatefulWidget {
  const CoachViewAllDiscussionsScreen({super.key});

  @override
  State<CoachViewAllDiscussionsScreen> createState() =>
      _CoachViewAllDiscussionsScreenState();
}

class _CoachViewAllDiscussionsScreenState
    extends State<CoachViewAllDiscussionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false)
          .fetchUsersWithMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Discussion',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
        leading: BackButton(
          color: black,
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/homeCoach");
          },
        ),
        actions: [
          Bounceable(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const CoachCreateDiscussionScreen();
                }),
              );

              if (result == 'single_message_sent' ||
                  result == 'group_created') {
                Provider.of<MessageProvider>(context, listen: false)
                    .fetchUsersWithMessages();
              }
            },
            child: Container(
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
              child: SvgPicture.asset(
                "assets/icones/plus.svg",
                color: white,
                width: MediaQuery.of(context).size.width * 0.047,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.048),
            //buildOnlineUsers(context),
            //SizedBox(height: MediaQuery.of(context).size.height * 0.024),
           // Divider(
            //  color: secondaryColor,
             // indent: MediaQuery.of(context).size.height * 0.06375,
             // endIndent: MediaQuery.of(context).size.height * 0.06375,
             // thickness: 1,
           // ),
            //SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            secondSection(context),
          ],
        ),
      ),
    );
  }

  Widget buildOnlineUsers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.052,
        ),
        height: MediaQuery.of(context).size.height * 0.12,
        child: Consumer<MessageProvider>(
          builder: (context, messageProvider, child) {
            if (messageProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: black),
              );
            } else if (messageProvider.error != null) {
              return Center(child: Text('Error: ${messageProvider.error}'));
            } else if (messageProvider.usersWithMessages == null ||
                messageProvider.usersWithMessages!.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun utilisateur trouvé',
                  textAlign: TextAlign.center,
                ),
              );
            }

            List<UserOrGroupWithMessages> usersWithMessages =
                messageProvider.usersWithMessages!;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: usersWithMessages.length,
              itemBuilder: (context, index) {
                UserOrGroupWithMessages userOrGroup = usersWithMessages[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CoachDiscussionScreen(user: userOrGroup),
                            ),
                          );
                        },
                        child: userOrGroup.username == null
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.15,
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://res.cloudinary.com/dgeyyccmg/image/upload/v1721660767/uogbt4u4lnynl6ququjg.png',
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(
                                      color: black,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.15,
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://ui-avatars.com/api/?name=${userOrGroup.username}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(
                                      color: black,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.012),
                      Text(
                        userOrGroup.username ?? userOrGroup.groupName ?? '',
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget secondSection(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: black,
            ),
          );
        } else if (messageProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${messageProvider.error}',
              textAlign: TextAlign.center,
            ),
          );
        } else if (messageProvider.usersWithMessages == null ||
            messageProvider.usersWithMessages!.isEmpty) {
          return const Center(
            child: Text(
              'Aucune discussion trouvée',
              textAlign: TextAlign.center,
            ),
          );
        }

        List<UserOrGroupWithMessages>? usersWithMessages =
            messageProvider.usersWithMessages;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: usersWithMessages?.length,
          itemBuilder: (context, index) {
            UserOrGroupWithMessages userOrGroup = usersWithMessages![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CoachDiscussionScreen(user: userOrGroup),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.052,
                  vertical: MediaQuery.of(context).size.height * 0.012,
                ),
                child: Row(
                  children: [
                    userOrGroup.username == null
                        ? SizedBox(
                            height: MediaQuery.of(context).size.width * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://res.cloudinary.com/dgeyyccmg/image/upload/v1721660767/uogbt4u4lnynl6ququjg.png',
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                  color: black,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.width * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://ui-avatars.com/api/?name=${userOrGroup.username}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                  color: black,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userOrGroup.username ?? userOrGroup.groupName ?? '',
                            style: GoogleFonts.montserrat(
                              color: black,
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
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
      },
    );
  }
}
