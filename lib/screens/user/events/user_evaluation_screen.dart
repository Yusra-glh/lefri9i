import 'package:flutter/material.dart';
import 'package:gark_academy/screens/widgets/Note_expandable_widget.dart';
import 'package:gark_academy/services/provider/event_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserEvaluationScreen extends StatefulWidget {
  final int attendanceId;
  const UserEvaluationScreen({
    super.key,
    required this.attendanceId,
  });

  @override
  State<UserEvaluationScreen> createState() => _UserEvaluationScreenState();
}

class _UserEvaluationScreenState extends State<UserEvaluationScreen> {
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
                            editable: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
