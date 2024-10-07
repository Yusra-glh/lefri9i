import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/attendance_model.dart';
import 'package:gark_academy/models/event_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/screens/coach/events/coach_user_evaluation_screen.dart';
import 'package:gark_academy/services/provider/event_provider.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoachEventDetailsScreen extends StatefulWidget {
  final Event event;

  const CoachEventDetailsScreen({super.key, required this.event});

  @override
  State<CoachEventDetailsScreen> createState() =>
      _CoachEventDetailsScreenState();
}

class _CoachEventDetailsScreenState extends State<CoachEventDetailsScreen> {
  Map<int, bool> toggleStates = {};

  @override
  void initState() {
    super.initState();
    _fetchAndSetEventMembers();
  }

  Future<void> _fetchAndSetEventMembers() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.fetchEventMembers(widget.event.id);
    if (!mounted) return;
    setState(() {
      for (var member in eventProvider.members) {
        final attendance = widget.event.attendances.firstWhere(
          (a) => a?.adherent.id == member.id,
          orElse: () => Attendance(
            id: 0,
            adherent: member,
            present: false,
          ),
        );
        toggleStates[member.id] = attendance!.present;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          event.nomEvent,
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
          softWrap: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              eventCard(event),
              eventMembers(context, eventProvider.members, eventProvider,
                  event.type == "TEST_EVALUATION"),
            ],
          ),
        ),
      ),
    );
  }

  Widget eventMembers(BuildContext context, List<User> members,
      EventProvider eventProvider, bool isEvaluation) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.height * 0.024,
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.024,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: secondaryColorLight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Membres",
            style: GoogleFonts.montserrat(
              color: black,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.0385,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.024),
          ...members
              .map((member) => memberCard(member, eventProvider, isEvaluation)),
        ],
      ),
    );
  }

  Widget memberCard(
      User member, EventProvider eventProvider, bool isEvaluation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.12,
                  width: MediaQuery.of(context).size.width * 0.12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://ui-avatars.com/api/?name=${member.firstname}+${member.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(color: black),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Text(
                "${member.firstname} ${member.lastname}",
                style: GoogleFonts.montserrat(
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontSize: MediaQuery.of(context).size.width * 0.036,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isEvaluation)
                Row(
                  children: [
                    Bounceable(
                      onTap: () {
                        final attendance = widget.event.attendances.firstWhere(
                          (a) => a?.adherent.id == member.id,
                          orElse: () => Attendance(
                              id: 0, adherent: member, present: false),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return CoachUserEvaluationScreen(
                                memberId: member.id,
                                attendanceId: attendance!.id);
                          }),
                        );
                      },
                      child: SvgPicture.asset(
                        "assets/icones/note.svg",
                        color: black,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.024),
                  ],
                ),
              Switch(
                value: toggleStates[member.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    toggleStates[member.id] = value;
                  });
                  eventProvider
                      .updateEventAttendance(
                    widget.event.attendances
                        .firstWhere((a) => a?.adherent.id == member.id)!
                        .id,
                    value,
                  )
                      .then((_) {
                    if (mounted) {
                      setState(() {
                        toggleStates[member.id] = value;
                      });
                    }
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget eventCard(Event event) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.height * 0.024,
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.024,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: secondaryColorLight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.nomEvent,
            style: GoogleFonts.montserrat(
              color: black,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.0385,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.006),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Date: ",
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width * 0.0315,
                  ),
                ),
                TextSpan(
                  text: formatEventDate(event.date),
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.006),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Heure: ",
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width * 0.0315,
                  ),
                ),
                TextSpan(
                  text: formatEventTime(event.heure ?? "09:00:00"),
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.006),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Lieu: ",
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width * 0.0315,
                  ),
                ),
                TextSpan(
                  text: event.statut,
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.006),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Description: ",
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width * 0.0315,
                  ),
                ),
                TextSpan(
                  text: event.description,
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
