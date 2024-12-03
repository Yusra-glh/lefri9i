import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/utils/colors.dart';

class MedicalInfoUpdateScreen extends StatefulWidget {
  const MedicalInfoUpdateScreen({super.key});

  @override
  _MedicalInfoUpdateScreenState createState() =>
      _MedicalInfoUpdateScreenState();
}

class _MedicalInfoUpdateScreenState extends State<MedicalInfoUpdateScreen> {
  final MemberService _userService = MemberService();

  final TextEditingController _conditionMedicaleController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicamentActuelController =
      TextEditingController();
  final TextEditingController _medicamentPassesController =
      TextEditingController();

  bool isLoading = true;
  bool isUpdating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedicalInfo();
  }

  Future<void> _fetchMedicalInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      print(
          'this is the condition medicale: ${prefs.getString('userConditionMedicale')}');
      _conditionMedicaleController.text =
          prefs.getString('userConditionMedicale') ?? '';

      print('this is ALLERGIEEEEEEEEEEE ${prefs.getString('userAllergies')}');
      _allergiesController.text = prefs.getString('userAllergies') != null
          ? (jsonDecode(prefs.getString('userAllergies')!) as List<dynamic>)
              .join(',')
          : '';

      _medicamentActuelController.text =
          prefs.getString('userMedicamentActuel') != null
              ? (jsonDecode(prefs.getString('userMedicamentActuel')!)
                      as List<dynamic>)
                  .join(',')
              : '';

      _medicamentPassesController.text =
          prefs.getString('userMedicamentPasses') != null
              ? (jsonDecode(prefs.getString('userMedicamentPasses')!)
                      as List<dynamic>)
                  .join(',')
              : '';

      isLoading = false;
    });
  }

  void _updateMedicalInfo() async {
    setState(() {
      isUpdating = true;
      errorMessage = null;
    });

    try {
      int userId = await _userService.getConnectedUserId();

      Map<String, dynamic> medicalInfo = {
        "conditionMedicale": _conditionMedicaleController.text,
        "allergies": _allergiesController.text.split(','),
        "medicamentActuel": _medicamentActuelController.text.split(','),
        "medicamentPasses": _medicamentPassesController.text.split(','),
      };

      await _userService.updateUserMedicalInformation(userId, medicalInfo);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'conditionMedicale', _conditionMedicaleController.text);
      await prefs.setStringList(
          'allergies', _allergiesController.text.split(','));
      await prefs.setStringList(
          'medicamentActuel', _medicamentActuelController.text.split(','));
      await prefs.setStringList(
          'medicamentPasses', _medicamentPassesController.text.split(','));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to update medical information';
      });
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Modifier Informations',
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.05,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Condition Medicale
                    TextFormField(
                      //controller
                      controller: _conditionMedicaleController,
                      //decoration
                      keyboardType: TextInputType.name,
                      cursorColor: black,
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: black,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText: "Condition Médicale",
                        hintText: "Condition Médicale",

                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        floatingLabelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: 1.5),
                        ),
                      ),
                    ),
                    //
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    // Allergies
                    TextFormField(
                      //controller
                      controller: _allergiesController,
                      //decoration
                      keyboardType: TextInputType.name,
                      cursorColor: black,
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: black,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText: "Allergies (séparées par des virgules)",
                        hintText: "Allergies (séparées par des virgules)",

                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        floatingLabelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: 1.5),
                        ),
                      ),
                    ),
                    //
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    // Medicament Actuel
                    TextFormField(
                      //controller
                      controller: _medicamentActuelController,
                      //decoration
                      keyboardType: TextInputType.name,
                      cursorColor: black,
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: black,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText:
                            "Médicaments Actuels (séparés par des virgules)",
                        hintText:
                            "Médicaments Actuels (séparés par des virgules)",

                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        floatingLabelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: 1.5),
                        ),
                      ),
                    ),
                    //
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    // Medicament Passes
                    TextFormField(
                      //controller
                      controller: _medicamentPassesController,
                      //decoration
                      keyboardType: TextInputType.name,
                      cursorColor: black,
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: black,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText:
                            "Médicaments Passés (séparés par des virgules)",
                        hintText:
                            "Médicaments Passés (séparés par des virgules)",

                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        floatingLabelStyle: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: black, width: 1.5),
                        ),
                      ),
                    ),
                    //
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Center(
                      child: MaterialButton(
                        onPressed: isUpdating ? null : _updateMedicalInfo,
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
                        child: isUpdating
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Modifier".toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.047,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
