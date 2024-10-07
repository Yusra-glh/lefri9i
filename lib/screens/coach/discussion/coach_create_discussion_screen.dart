import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/message_service.dart';
import 'package:gark_academy/services/provider/coach_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:gark_academy/widgets/tab_item.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachCreateDiscussionScreen extends StatefulWidget {
  const CoachCreateDiscussionScreen({super.key});

  @override
  State<CoachCreateDiscussionScreen> createState() =>
      _CoachCreateDiscussionScreenState();
}

class _CoachCreateDiscussionScreenState
    extends State<CoachCreateDiscussionScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  List<User> selectedUsers = [];
  TextEditingController groupNameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {
          selectedIndex = tabController.index;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoachProvider>(context, listen: false).fetchUsers();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Créer Un Groupe',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
        leading: BackButton(
          color: black,
          onPressed: () {
            Navigator.pop(context, 'single_message_sent');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.052,
          right: MediaQuery.of(context).size.width * 0.052,
          bottom: 0,
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 0,
                left: MediaQuery.of(context).size.width * 0.027,
                right: MediaQuery.of(context).size.width * 0.027,
                bottom: 0,
              ),
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.grey),
              ),
              child: TabBar(
                controller: tabController,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: _onTabTapped,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: Colors.black,
                ),
                indicatorColor: Colors.black,
                dividerColor: Colors.transparent,
                tabs: [
                  EventTabItem(
                    title: 'Tous'.toUpperCase(),
                    isSelected: selectedIndex == 0,
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                  ),
                  EventTabItem(
                    title: 'Membre'.toUpperCase(),
                    isSelected: selectedIndex == 1,
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                  ),
                  EventTabItem(
                    title: 'Coach'.toUpperCase(),
                    isSelected: selectedIndex == 2,
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                  ),
                  EventTabItem(
                    title: 'Staff'.toUpperCase(),
                    isSelected: selectedIndex == 3,
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.062),
            Expanded(
              child: Consumer<CoachProvider>(
                builder: (context, coachProvider, child) {
                  if (coachProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (coachProvider.errorMessage != null) {
                    return Center(child: Text(coachProvider.errorMessage!));
                  }

                  final users = coachProvider.users;

                  return TabBarView(
                    controller: tabController,
                    children: [
                      buildTabContent(context, users),
                      buildTabContent(
                          context,
                          users
                              .where((user) => user.role == 'ADHERENT')
                              .toList()),
                      buildTabContent(
                          context,
                          users
                              .where((user) => user.role == 'ENTRAINEUR')
                              .toList()),
                      buildTabContent(context,
                          users.where((user) => user.role == 'STAFF').toList()),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20,
              ),
              child: confirmButton(context, selectedUsers.length),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(BuildContext context, List<User> users) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () => _toggleUserSelection(user),
                child: Container(
                  color: selectedUsers.contains(user)
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 20,
                          bottom: 10,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 0.18,
                          width: MediaQuery.of(context).size.width * 0.18,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://ui-avatars.com/api/?name=${user.firstname}+${user.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(color: black),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${user.firstname} ${user.lastname}',
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage(int receiverId) async {
    final messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    try {
      final messageService = MessageService();

      await messageService.sendMessage(
        receiversId: [receiverId],
        message: messageText,
        idEquipe: null,
      );

      _textController.clear();
      Navigator.pop(
        context,
      );
      Navigator.pop(context, 'single_message_sent');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Widget confirmButton(BuildContext context, int selectedUsersCount) {
    return MaterialButton(
      onPressed: () {
        //logic here
        if (selectedUsersCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sélectionnez au moins un utilisateur'),
            ),
          );
          return;
        } else if (selectedUsersCount == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Entrer votre message',
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.0385,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.042),
                      TextFormField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: secondaryColor,
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        decoration: InputDecoration(
                          hintText: "Aa ...",
                          hintStyle: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w200,
                            fontSize: MediaQuery.of(context).size.width * 0.038,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: secondaryColor, width: .5),
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: secondaryColor, width: 1.5),
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.042),
                      MaterialButton(
                        onPressed: () {
                          print(
                              'Send message to user: ${selectedUsers.first.id}');
                          _sendMessage(selectedUsers.first.id);
                        },
                        height: MediaQuery.of(context).size.height * 0.054,
                        minWidth: MediaQuery.of(context).size.width * 0.65,
                        color: primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal: MediaQuery.of(context).size.width * 0.13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Text(
                          "Envoyer".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: white,
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.of(context).size.width * 0.047,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ajouter un nom',
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.0385,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.042),
                      TextFormField(
                        controller: groupNameController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: secondaryColor,
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        decoration: InputDecoration(
                          hintText: "Nom du groupe ...",
                          hintStyle: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w200,
                            fontSize: MediaQuery.of(context).size.width * 0.038,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: secondaryColor, width: .5),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: secondaryColor, width: 1.5),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.042),
                      MaterialButton(
                        onPressed: () {
                          if (groupNameController.text.isNotEmpty &&
                              selectedUsers.isNotEmpty) {
                            final groupName = groupNameController.text;
                            final groupMembers =
                                selectedUsers.map((user) => user.id).toList();

                            Provider.of<CoachProvider>(context, listen: false)
                                .createGroup(
                                    groupName: groupName, members: groupMembers)
                                .then((_) {
                              Navigator.pop(
                                context,
                              );
                              Navigator.pop(context, 'single_message_sent');
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error creating group: $error')),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Please enter a group name and select users'),
                              ),
                            );
                          }
                        },
                        height: MediaQuery.of(context).size.height * 0.054,
                        minWidth: MediaQuery.of(context).size.width * 0.65,
                        color: primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal: MediaQuery.of(context).size.width * 0.13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Text(
                          "Ajouter".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: white,
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.of(context).size.width * 0.047,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      height: MediaQuery.of(context).size.height * 0.054,
      minWidth: MediaQuery.of(context).size.width * 0.65,
      color: primaryColor,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.012,
        horizontal: MediaQuery.of(context).size.width * 0.13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Text(
        "confirmer".toUpperCase(),
        style: GoogleFonts.montserrat(
          color: white,
          fontWeight: FontWeight.w700,
          fontSize: MediaQuery.of(context).size.width * 0.047,
        ),
      ),
    );
  }
}
