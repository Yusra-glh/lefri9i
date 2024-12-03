import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/models/attendance_model.dart';
import 'package:gark_academy/models/training_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/provider/training_provider.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoachTrainingDetailsScreen extends StatefulWidget {
  final Training training;

  const CoachTrainingDetailsScreen({super.key, required this.training});

  @override
  State<CoachTrainingDetailsScreen> createState() =>
      _CoachTrainingDetailsScreenState();
}

class _CoachTrainingDetailsScreenState
    extends State<CoachTrainingDetailsScreen> {
  Map<int, bool> toggleStates = {};

  @override
  void initState() {
    super.initState();
    final trainingProvider =
        Provider.of<TrainingProvider>(context, listen: false);
    trainingProvider.fetchTrainingMembers(widget.training.id).then((_) {
      setState(() {
        for (var member in trainingProvider.members) {
          final attendance = widget.training.attendances?.firstWhere(
            (a) => a!.adherent.id == member.id,
            orElse: () => Attendance(
              id: 0,
              adherent: member,
              present: false,
            ),
          );
          toggleStates[member.id] = attendance!.present;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final training = widget.training;
    final trainingProvider = Provider.of<TrainingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Entraînement",
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
              trainingCard(training),
              eventMembers(context, trainingProvider.members, trainingProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget eventMembers(BuildContext context, List<User> members,
      TrainingProvider trainingProvider) {
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
              .map((member) => memberCard(member, trainingProvider))
              .toList(),
        ],
      ),
    );
  }

  Widget memberCard(User member, TrainingProvider trainingProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.14,
                width: MediaQuery.of(context).size.width * 0.14,
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
            Switch(
                value: toggleStates[member.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    toggleStates[member.id] = value;
                  });
                  trainingProvider
                      .updateTrainingAttendance(
                    widget.training.attendances!
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
                })
          ],
        )
      ],
    );
  }

  Widget trainingCard(Training training) {
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
            "Entraînement",
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
                  text: formatEventDate(training.date),
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
                  text: formatEventTime(training.heure!),
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
                  text: "Terrain: ",
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w300,
                    fontSize: MediaQuery.of(context).size.width * 0.0315,
                  ),
                ),
                TextSpan(
                  text: training.terrain,
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
        ],
      ),
    );
  }
}
