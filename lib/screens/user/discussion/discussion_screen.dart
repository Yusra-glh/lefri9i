import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/message_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/screens/user/discussion/view_all_messages.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/message_service.dart';
import 'package:gark_academy/services/provider/member_provider.dart';
import 'package:gark_academy/utils/Constants.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DiscussionScreen extends StatefulWidget {
  final UserOrGroupWithMessages user;
  const DiscussionScreen({super.key, required this.user});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  final MessageService _messageService = MessageService();
  final MemberService _userService = MemberService();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  String? errorMessage;
  User? connectedUser;
  String? selectedMessage;

  bool isGroup = true;
  List<MessageModel> messages = [];
  User? user;

  @override
  void initState() {
    super.initState();
    isGroupOrUser();
    fetchChatHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCoachData();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _messagesFuture = _fetchMessages();
  //   getConnectedUser();
  // }

  // Future<void> getConnectedUser() async {
  //   try {
  //     final userId = await _userService.getConnectedUserId();
  //     final fetchedUser = await _userService.getAdherantInformations(userId);
  //     if (!mounted) return;
  //     setState(() {
  //       connectedUser = fetchedUser;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() {
  //       errorMessage = 'Failed to load user profile';
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchCoachData() async {
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

  void isGroupOrUser() {
    isGroup = widget.user.groupId != null;
  }

  Future<void> fetchChatHistory() async {
    try {
      final messageService = MessageService();
      List<MessageModel> fetchedMessages;
      if (isGroup) {
        fetchedMessages = await messageService.getChatHistory(
          equipeId: widget.user.groupId,
        );
      } else {
        fetchedMessages = await messageService.getChatHistory(
          userId2: widget.user.userId,
        );
      }

      setState(() {
        messages = fetchedMessages.reversed.toList();
        isLoading = false;
      });

      // Scroll to bottom after messages are updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching chat history: $e');
    }
  }

  // Future<List<MessageModel>> _fetchMessages() async {
  //   try {
  //     List<MessageModel> messages =
  //         await _messageService.getChatHistory(widget.user.userId);
  //     return messages.reversed.toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

  Future<void> _updateDiscussion() async {
    setState(() {
      fetchChatHistory();
    });
  }

  Future<void> _sendMessage() async {
    if (selectedMessage != null && selectedMessage!.isNotEmpty) {
      try {
        final messageService = MessageService();
        if (isGroup) {
          await messageService.sendMessage(
            receiversId: [],
            message: selectedMessage!,
            idEquipe: widget.user.groupId,
          );
        } else {
          await messageService.sendMessage(
            receiversId: [widget.user.userId],
            message: selectedMessage!,
            idEquipe: null,
          );
        }
        setState(() {
          selectedMessage = null;
          fetchChatHistory();
        });
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Future<void> _sendMessage() async {
  //   if (selectedMessage != null && selectedMessage!.isNotEmpty) {
  //     try {
  //       await _messageService.sendMessage(
  //         receiversId: [widget.user.userId],
  //         message: selectedMessage!,
  //         idEquipe: null,
  //       );
  //       setState(() {
  //         selectedMessage = null;
  //         _messagesFuture = _fetchMessages();
  //       });
  //       _scrollToBottom();
  //     } catch (e) {
  //       print('Failed to send message: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          isGroup ? '${widget.user.groupName}' : '${widget.user.username}',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
        leading: BackButton(
          color: black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            getMessageHistory(context),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.018,
              right: MediaQuery.of(context).size.width * 0.0385,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  buildSelectAccountPopup(context);
                },
                backgroundColor: primaryColor,
                child: SvgPicture.asset(
                  'assets/icones/send.svg',
                  color: white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getMessageHistory(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        //top: MediaQuery.of(context).size.height * 0.024,
        left: MediaQuery.of(context).size.height * 0.01,
        right: MediaQuery.of(context).size.height * 0.01,
        bottom: MediaQuery.of(context).size.height * 0.08,
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : messages.isEmpty
              ? const Center(
                  child: Text(
                    'No messages',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: messages.length,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.042,
                  ),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return message.senderId == user?.id
                        ? messageSent(context, message, message.senderName!)
                        : messageReceived(
                            context, message, message.senderName!);
                  },
                ),
    );
  }

  Future<dynamic> buildSelectAccountPopup(BuildContext context) {
    //fast suggestions is the the two first messages from adherantMessagesList
    List<String> fastSuggestions = adherantMessagesList.sublist(0, 2);

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.036,
                left: MediaQuery.of(context).size.width * 0.027,
                right: MediaQuery.of(context).size.width * 0.078,
                bottom: MediaQuery.of(context).size.height * 0.024,
              ),
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
                border: Border.all(
                  color: secondaryColor,
                  width: .5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...fastSuggestions.map(
                    (suggestion) => Bounceable(
                      onTap: () {
                        if (selectedMessage == suggestion) {
                          setModalState(() {
                            selectedMessage = null;
                          });
                        } else {
                          setModalState(() {
                            selectedMessage = suggestion;
                          });
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: MediaQuery.of(context).size.height * 0.024,
                        ),
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.006,
                          right: MediaQuery.of(context).size.width * 0.0125,
                          left: MediaQuery.of(context).size.width * 0.0125,
                          bottom: MediaQuery.of(context).size.height * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: selectedMessage == suggestion
                              ? incomingMessageBackground
                              : white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                          border: selectedMessage == suggestion
                              ? null
                              : Border.all(
                                  color: primaryColor,
                                  width: .5,
                                ),
                        ),
                        child: ListTile(
                          title: Text(
                            suggestion,
                            style: GoogleFonts.montserrat(
                              color: black,
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        overlayColor: grey.withOpacity(0.5),
                      ),
                      onPressed: () {
                        //logic here
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllMessagesScreen(
                              idEquipe: widget.user.groupId,
                              idUser: widget.user.userId,
                              isGroup: isGroup,
                              onUpdateMessages: _updateDiscussion,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "voir tout",
                        style: GoogleFonts.montserrat(
                          color: secondaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                          decoration: TextDecoration.underline,
                          decorationColor: secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                  sendButton(context, selectedMessage),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        selectedMessage = null;
      });
    });
  }

  Widget sendButton(BuildContext context, String? selectedMessage) {
    return MaterialButton(
      onPressed: () {
        _sendMessage();
        Navigator.pop(context);
      },

      // Style and other button properties
      height: MediaQuery.of(context).size.height * 0.054,
      minWidth: MediaQuery.of(context).size.width * 0.65,
      elevation: selectedMessage == null ? 0 : 5,
      color: selectedMessage == null ? unselectedButton : primaryColor,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.012,
        horizontal: MediaQuery.of(context).size.width * 0.125,
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
    );
  }

  String _formatTimestamp(String timestamp) {
    DateTime parsedTime = DateTime.parse(timestamp);
    Duration difference = DateTime.now().difference(parsedTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget messageSent(
      BuildContext context, MessageModel message, String senderName) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w200,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.029,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 0.0024),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.018,
                            right: MediaQuery.of(context).size.width * 0.0385,
                            left: MediaQuery.of(context).size.width * 0.0385,
                            bottom: MediaQuery.of(context).size.height * 0.018,
                          ),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                            ),
                            border: Border.all(
                              color: primaryColor,
                              width: .5,
                            ),
                          ),
                          child: Text(
                            message.message,
                            style: GoogleFonts.montserrat(
                              color: black,
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0325,
                            ),
                            softWrap: true,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.048,
                    width: MediaQuery.of(context).size.width * 0.104,
                    margin: EdgeInsets.only(
                      top: 0,
                      left: MediaQuery.of(context).size.width * 0.027,
                      right: 0,
                      bottom: 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://ui-avatars.com/api/?name=${senderName}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          color: black,
                        ),
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.024),
      ],
    );
  }

  Widget messageReceived(
      BuildContext context, MessageModel message, String senderName) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.048,
                    width: MediaQuery.of(context).size.width * 0.104,
                    margin: EdgeInsets.only(
                      top: 0,
                      left: 0,
                      right: MediaQuery.of(context).size.width * 0.027,
                      bottom: 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://ui-avatars.com/api/?name=${senderName}&uppercase=true&color=ffffff&background=000000&rounded=true&size=512&size=150',
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          color: black,
                        ),
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              senderName,
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w200,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.029,
                              ),
                            ),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: GoogleFonts.montserrat(
                                color: black,
                                fontWeight: FontWeight.w200,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.029,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 0.0024),
                        Container(
                          //width: double.infinity,  //In case the bubble needs to take the width of the screen
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.018,
                            right: MediaQuery.of(context).size.width * 0.0385,
                            left: MediaQuery.of(context).size.width * 0.0385,
                            bottom: MediaQuery.of(context).size.height * 0.018,
                          ),
                          decoration: const BoxDecoration(
                            color: incomingMessageBackground,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Text(
                            message.message,
                            style: GoogleFonts.montserrat(
                              color: black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0325,
                            ),
                            softWrap: true,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.024),
      ],
    );
  }
}
