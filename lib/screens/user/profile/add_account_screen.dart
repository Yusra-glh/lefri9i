import 'package:flutter/material.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _teamCodeController;
  bool _obscurePassword = true;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _teamCodeController = TextEditingController();
    super.initState();
  }

  Future<void> registerUser(BuildContext context) async {
    final String firstname = _firstNameController.text;
    final String lastname = _lastNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String telephone = _phoneController.text;
    final String teamCode = _teamCodeController.text;

    try {
      final notifProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final fcmToken = await notifProvider.getFcmToken();

      final AuthService authService = AuthService();
      final response = await authService.registerAdherant(
          firstname: firstname,
          lastname: lastname,
          email: email,
          telephone: telephone,
          password: password,
          teamCode: teamCode,
          fcmToken: fcmToken ?? "");

      if (response.statusCode == 200) {
        const SnackBar(
          content: Text('Compte créé avec succès.'),
          duration: Duration(seconds: 3),
        );

        // Fetch the user role from shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? email = prefs.getString('userEmail');
        if (email != null) {
          notifProvider.connectWebSocket(email);
        }
        String? userRole = prefs.getString('userRole');

        if (userRole == 'ADHERENT') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/homeUser',
            (route) => false,
          );
        } else if (userRole == 'ENTRAINEUR') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/homeCoach',
            (route) => false,
          );
        }
      } else {
        final responseBody = response.data;

        if (responseBody['message'] == 'Email existe déja') {
          // Show a SnackBar with the error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email existe déjà.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (responseBody['message'] == 'Equipe introuvable') {
          // Show a SnackBar with the error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code d\'équipe n\'existe pas.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // ignore: avoid_print
          print('Failed with status code: ${response.statusCode}');
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              //in french
              content: Text(
                  'L\'enregistrement a échoué. Essayez de nouveau plus tard.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error register: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('L\'enregistrement a échoué. Essayez de nouveau plus tard.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: darkgrey,
        title: Text(
          'Ajouter un compte',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.05,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          bottom: 0,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //
                //name textfield
                //
                TextFormField(
                  //controller
                  controller: _firstNameController,
                  validator: (value) {
                    return null;
                  },
                  //decoration
                  keyboardType: TextInputType.name,
                  cursorColor: darkgrey,
                  style: GoogleFonts.montserrat(
                    color: darkgrey,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
                    decorationColor: darkgrey,
                  ),
                  decoration: InputDecoration(
                    //contentPadding: const EdgeInsets.all(5),
                    labelText: "Nom",
                    hintText: "Entez votre nom",
                    //person icon
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.052,
                        left: MediaQuery.of(context).size.width * 0.027,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: darkgrey.withOpacity(.5),
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    //
                    //before clicking the textfield
                    //
                    // label before clicking the texfield
                    labelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //textfield border
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: .5),
                    ),
                    //
                    //after clicking the textfield
                    //
                    //hint after clicking the textfield
                    hintStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                    //floating label
                    floatingLabelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //focused border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: 1.5),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                TextFormField(
                  //controller
                  controller: _lastNameController,
                  validator: (value) {
                    return null;
                  },
                  //decoration
                  keyboardType: TextInputType.name,
                  cursorColor: darkgrey,
                  style: GoogleFonts.montserrat(
                    color: darkgrey,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
                    decorationColor: darkgrey,
                  ),
                  decoration: InputDecoration(
                    //contentPadding: const EdgeInsets.all(5),
                    labelText: "Prénom",
                    hintText: "Entez votre prénom",
                    //person icon
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.052,
                        left: MediaQuery.of(context).size.width * 0.027,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: darkgrey.withOpacity(.5),
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    //
                    //before clicking the textfield
                    //
                    // label before clicking the texfield
                    labelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //textfield border
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: .5),
                    ),
                    //
                    //after clicking the textfield
                    //
                    //hint after clicking the textfield
                    hintStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                    //floating label
                    floatingLabelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //focused border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: 1.5),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                //
                //phone textfield
                //
                TextFormField(
                  //controller
                  controller: _phoneController,
                  validator: (value) {
                    return null;
                  },
                  //decoration
                  keyboardType: TextInputType.phone,
                  cursorColor: darkgrey,
                  style: GoogleFonts.montserrat(
                    color: darkgrey,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
                    decorationColor: darkgrey,
                  ),
                  decoration: InputDecoration(
                    //contentPadding: const EdgeInsets.all(5),
                    labelText: "Téléphone",
                    hintText: "Entez votre numéro de téléphone",
                    //phone icon
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.052,
                        left: MediaQuery.of(context).size.width * 0.027,
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: darkgrey.withOpacity(.5),
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    //
                    //before clicking the textfield
                    //
                    // label before clicking the texfield
                    labelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //textfield border
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: .5),
                    ),
                    //
                    //after clicking the textfield
                    //
                    //hint after clicking the textfield
                    hintStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                    //floating label
                    floatingLabelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //focused border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: 1.5),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                //
                //email textfield
                //
                TextFormField(
                  //controller
                  controller: _emailController,
                  validator: (value) {
                    return null;
                  },
                  //decoration
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: darkgrey,
                  style: GoogleFonts.montserrat(
                    color: darkgrey,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
                    decorationColor: darkgrey,
                  ),
                  decoration: InputDecoration(
                    //contentPadding: const EdgeInsets.all(5),
                    labelText: "Email",
                    hintText: "Entez votre adresse mail",
                    //email icon
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.052,
                        left: MediaQuery.of(context).size.width * 0.027,
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        color: darkgrey.withOpacity(.5),
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    //
                    //before clicking the textfield
                    //
                    // label before clicking the texfield
                    labelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //textfield border
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: .5),
                    ),
                    //
                    //after clicking the textfield
                    //
                    //hint after clicking the textfield
                    hintStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                    //floating label
                    floatingLabelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //focused border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: 1.5),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                TextFormField(
                  //controller
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                  //decoration
                  obscureText: _obscurePassword,
                  cursorColor: darkgrey,
                  style: GoogleFonts.montserrat(
                    color: darkgrey,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
                    decorationColor: darkgrey,
                  ),
                  decoration: InputDecoration(
                    //contentPadding: const EdgeInsets.all(5),
                    labelText: 'Mot de passe',
                    hintText: 'Saissisez votre mot de passe',
                    //password lock icon
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.052,
                        left: MediaQuery.of(context).size.width * 0.027,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: darkgrey,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    //password eye icon with show and hide password
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: darkgrey,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    //
                    //before clicking the textfield
                    //
                    // label before clicking the texfield
                    labelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //textfield border
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: .5),
                    ),
                    //
                    //after clicking the textfield
                    //
                    //hint after clicking the textfield
                    hintStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                    //floating label
                    floatingLabelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //focused border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                //
                //team code textfield
                //
                TextFormField(
                  //controller
                  controller: _teamCodeController,
                  validator: (value) {
                    return null;
                  },
                  //decoration
                  keyboardType: TextInputType.number,
                  cursorColor: darkgrey,
                  style: GoogleFonts.montserrat(
                    color: darkgrey,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.038,
                    decorationColor: darkgrey,
                  ),
                  decoration: InputDecoration(
                    //contentPadding: const EdgeInsets.all(5),
                    labelText: "Code d'équipe",
                    hintText: "Entez votre code d'équipe",
                    //code icon
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.052,
                        left: MediaQuery.of(context).size.width * 0.027,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: darkgrey.withOpacity(.5),
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                    //
                    //before clicking the textfield
                    //
                    // label before clicking the texfield
                    labelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //textfield border
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: .5),
                    ),
                    //
                    //after clicking the textfield
                    //
                    //hint after clicking the textfield
                    hintStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w200,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                    //floating label
                    floatingLabelStyle: GoogleFonts.montserrat(
                      color: darkgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                    //focused border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: darkgrey, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                confirmButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MaterialButton confirmButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        registerUser(context);
      },
      // Style and other button properties
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
