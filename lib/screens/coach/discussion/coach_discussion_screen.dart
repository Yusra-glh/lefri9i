import 'package:flutter/material.dart';
import 'package:gark_academy/models/message_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/message_service.dart';
import 'package:gark_academy/services/provider/coach_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoachDiscussionScreen extends StatefulWidget {
  final UserOrGroupWithMessages user;

  const CoachDiscussionScreen({super.key, required this.user});

  @override
  State<CoachDiscussionScreen> createState() => _CoachDiscussionScreenState();
}

class _CoachDiscussionScreenState extends State<CoachDiscussionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  bool isGroup = true;
  List<MessageModel> messages = [];
  bool isLoading = true;
  User? user;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    isGroupOrUser();
    fetchChatHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCoachData();
    });
  }

  Future<void> _fetchCoachData() async {
    try {
      final coachProvider = Provider.of<CoachProvider>(context, listen: false);
      await coachProvider.fetchCoach();
      setState(() {
        user = coachProvider.user;
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

  Future<void> _sendMessage() async {
    final messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    try {
      final messageService = MessageService();
      if (isGroup) {
        await messageService.sendMessage(
          receiversId: [],
          message: messageText,
          idEquipe: widget.user.groupId,
        );
      } else {
        await messageService.sendMessage(
          receiversId: [widget.user.userId],
          message: messageText,
          idEquipe: null,
        );
      }

      _textController.clear();
      fetchChatHistory();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        // actions: [
        //   Bounceable(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) {
        //           return const CoachEditDiscussionScreen();
        //         }),
        //       );
        //     },
        //     child: Container(
        //       margin: EdgeInsets.only(
        //         right: MediaQuery.of(context).size.width * 0.027,
        //       ),
        //       padding: EdgeInsets.all(
        //         MediaQuery.of(context).size.height * 0.012,
        //       ),
        //       decoration: BoxDecoration(
        //         color: white,
        //         borderRadius: BorderRadius.circular(50),
        //       ),
        //       child: SvgPicture.asset(
        //         "assets/icones/vertical_dots.svg",
        //         color: black,
        //         width: MediaQuery.of(context).size.width * 0.052,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            getMessageHistory(context),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.042,
                  vertical: MediaQuery.of(context).size.height * 0.012,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: black,
                              size: MediaQuery.of(context).size.width * 0.07,
                            ),
                            onPressed: _sendMessage,
                          ),
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
                    ),
                  ],
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
                      child: Image.network(
                        'https://ui-avatars.com/api/?name=${senderName}&uppercase=true&color=ffffff&background=000000&rounded=true',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            color: black,
                          );
                        },
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
                      child: Image.network(
                        'https://ui-avatars.com/api/?name=${senderName}&uppercase=true&color=ffffff&background=000000&rounded=true',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            color: black,
                          );
                        },
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
                              '$senderName ',
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
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.018,
                            right: MediaQuery.of(context).size.width * 0.0385,
                            left: MediaQuery.of(context).size.width * 0.0385,
                            bottom: MediaQuery.of(context).size.height * 0.018,
                          ),
                          decoration: BoxDecoration(
                            color: incomingMessageBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                              topRight: Radius.circular(40),
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
}
