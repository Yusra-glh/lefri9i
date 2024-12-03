import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/models/message_model.dart';
import 'package:gark_academy/screens/coach/discussion/coach_discussion_screen.dart';
import 'package:gark_academy/screens/user/discussion/discussion_screen.dart';
import 'package:gark_academy/services/message_service.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewAllDiscussionsScreen extends StatefulWidget {
  const ViewAllDiscussionsScreen({super.key});

  @override
  State<ViewAllDiscussionsScreen> createState() =>
      _CoachViewAllDiscussionsScreenState();
}

class _CoachViewAllDiscussionsScreenState
    extends State<ViewAllDiscussionsScreen> {
  final MessageService _messageService = MessageService();
  late Future<List<UserOrGroupWithMessages>> _usersWithMessagesFuture;

  @override
  void initState() {
    super.initState();
    _usersWithMessagesFuture = _fetchUsersWithMessages();

    print("this is the user with messages $_usersWithMessagesFuture");
  }

  Future<List<UserOrGroupWithMessages>> _fetchUsersWithMessages() async {
    try {
      return await _messageService.fetchUsersWithMessages();
    } catch (e) {
      throw Exception('Failed to load users or groups with messages: $e');
    }
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
            Navigator.pushReplacementNamed(context, "/homeUser");
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.024),
           // buildOnlineUsers(),
            //SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            //Divider(
              //color: secondaryColor,
              //indent: MediaQuery.of(context).size.height * 0.06375,
              //endIndent: MediaQuery.of(context).size.height * 0.06375,
              //thickness: 1,
            //),
           // SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            secondSection(context)
          ],
        ),
      ),
    );
  }

  Widget buildOnlineUsers() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
      ),
      child: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.052,
        ),
        height: MediaQuery.of(context).size.height * 0.12,
        child: FutureBuilder<List<UserOrGroupWithMessages>>(
          future: _usersWithMessagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: black,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun utilisateur trouvé',
                  textAlign: TextAlign.center,
                ),
              );
            }

            List<UserOrGroupWithMessages> usersWithMessages = snapshot.data!;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: usersWithMessages.length,
              itemBuilder: (context, index) {
                UserOrGroupWithMessages userOrGroup = usersWithMessages[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiscussionScreen(user: userOrGroup),
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
                                            color: black),
                                    //errorWidget: (context, url, error) => Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius:
                                    MediaQuery.of(context).size.width * 0.076,
                                backgroundImage: CachedNetworkImageProvider(
                                  'https://ui-avatars.com/api/?name=${userOrGroup.username}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
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
    return FutureBuilder<List<UserOrGroupWithMessages>>(
      future: _usersWithMessagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: black,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Aucune discussion trouvée',
              textAlign: TextAlign.center,
            ),
          );
        }

        List<UserOrGroupWithMessages> usersWithMessages = snapshot.data!;
        print("this is the user with messages $usersWithMessages");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: usersWithMessages.length,
          itemBuilder: (context, index) {
            UserOrGroupWithMessages userOrGroup = usersWithMessages[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscussionScreen(user: userOrGroup),
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
                                        color: black),
                                //errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.076,
                            backgroundImage: CachedNetworkImageProvider(
                              'https://ui-avatars.com/api/?name=${userOrGroup.username}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
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
