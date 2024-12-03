import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/message_service.dart';
import 'package:gark_academy/utils/Constants.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachViewAllMessagesScreen extends StatefulWidget {
  final User user;
  final VoidCallback onUpdateMessages;
  const CoachViewAllMessagesScreen(
      {super.key, required this.user, required this.onUpdateMessages});

  @override
  State<CoachViewAllMessagesScreen> createState() =>
      _CoachViewAllMessagesScreenState();
}

class _CoachViewAllMessagesScreenState
    extends State<CoachViewAllMessagesScreen> {
  final MessageService _messageService = MessageService();

  String? selectedMessage;
  Future<void> _sendMessage() async {
    if (selectedMessage != null && selectedMessage!.isNotEmpty) {
      try {
        await _messageService.sendMessage(
          receiversId: [widget.user.id],
          message: selectedMessage!,
          idEquipe: null,
        );
        setState(() {
          selectedMessage = null;
        });
        widget.onUpdateMessages();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        // ignore: avoid_print
        print('Failed to send message: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
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
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.036,
              left: MediaQuery.of(context).size.width * 0.052,
              right: MediaQuery.of(context).size.width * 0.052,
              bottom: MediaQuery.of(context).size.height * 0.024,
            ),
            height: MediaQuery.of(context).size.height,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...adherantMessagesList.map(
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
                                bottom:
                                    MediaQuery.of(context).size.height * 0.024,
                              ),
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.006,
                                right:
                                    MediaQuery.of(context).size.width * 0.0125,
                                left:
                                    MediaQuery.of(context).size.width * 0.0125,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.006,
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
                                        MediaQuery.of(context).size.width *
                                            0.0315,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                sendButton(context, selectedMessage),
              ],
            ),
          );
        },
      ),
    );
  }

  MaterialButton sendButton(BuildContext context, String? selectedMessage) {
    return MaterialButton(
      onPressed: () {
        _sendMessage();
      },
      // Style and other button properties
      height: MediaQuery.of(context).size.height * 0.054,
      minWidth: MediaQuery.of(context).size.width * 0.65,
      elevation: selectedMessage == null ? 0 : 5,
      color: selectedMessage == null ? unselectedButton : primaryColor,
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
    );
  }
}
