import 'package:flutter/material.dart';
import 'package:gark_academy/screens/widgets/Note_expandable_widget.dart';
import 'package:gark_academy/services/provider/event_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoachUserEvaluationScreen extends StatefulWidget {
  final int memberId;
  final int attendanceId;
  const CoachUserEvaluationScreen({
    super.key,
    required this.memberId,
    required this.attendanceId,
  });

  @override
  State<CoachUserEvaluationScreen> createState() =>
      _CoachUserEvaluationScreenState();
}

class _CoachUserEvaluationScreenState extends State<CoachUserEvaluationScreen> {
  @override
  void initState() {
    super.initState();
    fetchTestData();
  }

  void fetchTestData() async {
    await Provider.of<EventProvider>(context, listen: false)
        .fetchTestData(widget.attendanceId);
    print(
        "test data is ${Provider.of<EventProvider>(context, listen: false).testData}");
  }

  void updateTestData() async {
    final testData =
        Provider.of<EventProvider>(context, listen: false).testData;
    if (testData != null) {
      await Provider.of<EventProvider>(context, listen: false)
          .updateTestData(testData.id, testData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final testData = Provider.of<EventProvider>(context).testData;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Test d\'évaluation',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
          softWrap: true,
        ),
      ),
      body: testData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: testData.categories.map((category) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: NoteExpandableSection(
                            title: category.categorieName,
                            isExpanded: false,
                            categories: [category],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                    bottom: 25.0,
                  ),
                  child: confirmButton(context),
                ),
              ],
            ),
    );
  }

  Widget confirmButton(BuildContext context) {
    return MaterialButton(
      onPressed: updateTestData,
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
        "Confirmer".toUpperCase(),
        style: GoogleFonts.montserrat(
          color: white,
          fontWeight: FontWeight.w700,
          fontSize: MediaQuery.of(context).size.width * 0.047,
        ),
      ),
    );
  }
}
