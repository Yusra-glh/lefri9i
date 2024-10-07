import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/screens/widgets/week_header.dart';
import 'package:gark_academy/screens/widgets/week_view.dart';
import 'package:gark_academy/services/provider/event_provider.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/services/provider/training_provider.dart';
import 'package:provider/provider.dart';
import 'package:gark_academy/models/event_model.dart';
import 'package:gark_academy/models/training_model.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:gark_academy/widgets/tab_item_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAdherantEvents();
      Provider.of<TrainingProvider>(context, listen: false)
          .fetchAdherantTrainings();
    });
  }

  void onDaySelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Événements',
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
        body: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.052,
            right: MediaQuery.of(context).size.width * 0.052,
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.048),
              Container(
                margin: EdgeInsets.only(
                  top: 0,
                  left: MediaQuery.of(context).size.width * 0.027,
                  right: MediaQuery.of(context).size.width * 0.027,
                  bottom: 0,
                ),
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.grey),
                ),
                child: TabBar(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  //onTap: _onTabTapped,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: Colors.black,
                  ),
                  indicatorColor: Colors.black,
                  dividerColor: Colors.transparent,
                  tabs: [
                    EventTabItemIcon(
                      icon: SvgPicture.asset(
                        "assets/icones/list.svg",
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      isSelected: selectedIndex == 0,
                    ),
                    EventTabItemIcon(
                      icon: SvgPicture.asset(
                        "assets/icones/traffic-cone.svg",
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      isSelected: selectedIndex == 1,
                    ),
                    EventTabItemIcon(
                      icon: SvgPicture.asset(
                        "assets/icones/calendar.svg",
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      isSelected: selectedIndex == 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.048),
              Expanded(
                child: TabBarView(
                  children: [
                    buildEventList(),
                    buildTrainingList(),
                    buildEventCalendar(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Events

  Widget buildEventList() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return eventProvider.events.isEmpty
            ? Center(
                child: Text(
                  'Aucun événement à venir.',
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: eventProvider.events.length,
                itemBuilder: (context, index) {
                  return eventCard(eventProvider.events[index]);
                },
              );
      },
    );
  }

  Widget eventCard(Event event) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                        text: formatEventDateTime(
                            event.date, event.heure ?? "10:00:00"),
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
                        text: event.lieu,
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
          ),
        ],
      ),
    );
  }

  // Trainings

  Widget buildTrainingList() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        return trainingProvider.trainings.isEmpty
            ? Center(
                child: Text(
                  'Aucun événement à venir.',
                  style: GoogleFonts.montserrat(
                    color: grey,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: trainingProvider.trainings.length,
                itemBuilder: (context, index) {
                  return trainingCard(trainingProvider.trainings[index]);
                },
              );
      },
    );
  }

  Widget trainingCard(Training training) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Entrainement",
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
                        text: formatEventDateTime(
                            training.date, training.heure ?? "10:00:00"),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Calendar

  Widget buildEventCalendar(BuildContext context) {
    return Consumer2<EventProvider, TrainingProvider>(
      builder: (context, eventProvider, trainingProvider, child) {
        final filteredEventsList = eventProvider.events
            .where(
                (event) => isSameDate(DateTime.parse(event.date), selectedDate))
            .toList();

        final filteredTrainingsList = trainingProvider.trainings
            .where((training) =>
                isSameDate(DateTime.parse(training.date), selectedDate))
            .toList();

        final combinedList = [...filteredEventsList, ...filteredTrainingsList];

        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.006,
            bottom: MediaQuery.of(context).size.height * 0.018,
            left: 0,
            right: 0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.024),
                const WeekHeader(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.096,
                  child: PageView.builder(
                    controller: PageController(
                        initialPage: _getWeekNumber(selectedDate)),
                    itemBuilder: (context, index) {
                      return WeekView(
                        weekIndex: index,
                        selectedDate: selectedDate,
                        onDaySelected: (date) {
                          onDaySelected(date);
                        },
                      );
                    },
                  ),
                ),
                Divider(
                  color: secondaryColor,
                  indent: MediaQuery.of(context).size.width * 0.065,
                  endIndent: MediaQuery.of(context).size.width * 0.065,
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: combinedList.isEmpty
                        ? Center(
                            child: Text(
                              'Aucun événement ou entrainement prévus pour ce jour.',
                              style: GoogleFonts.montserrat(
                                color: grey,
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.0385,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            children: combinedList.map((item) {
                              if (item is Event) {
                                return eventCard(item);
                              } else if (item is Training) {
                                return trainingCard(item);
                              } else {
                                return Container();
                              }
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return (dayOfYear / 7).floor();
  }
}
