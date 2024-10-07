import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:gark_academy/screens/widgets/pdf_viewer.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _teamCodeController;
  bool _agreedToTOS = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _teamCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teamCodeController.dispose();
    super.dispose();
  }

  Future<void> registerUser(BuildContext context) async {
    log("---------------register  ");
    final String firstname = _firstnameController.text;
    final String lastname = _lastnameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String telephone = _phoneController.text;
    final String teamCode = _teamCodeController.text;

    try {
      final notifProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      log("---------------notifProvider:  ");
      final fcmToken = await notifProvider.getFcmToken();
      log("---------------fcmToken:  $fcmToken");

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
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: const AssetImage("assets/images/background.jpg"),
            //color filter
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.darken),
            fit: BoxFit.cover,
          )),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.052,
                right: MediaQuery.of(context).size.width * 0.052,
                top: MediaQuery.of(context).size.height * 0.012,
                bottom: 0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Skip button
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/offlineHomePage");
                        },
                        child: Text(
                          "Skip",
                          style: GoogleFonts.montserrat(
                            color: secondaryColor,
                            fontWeight: FontWeight.w200,
                            fontSize: MediaQuery.of(context).size.width * 0.042,
                            decoration: TextDecoration.underline,
                            decorationColor: secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.048),
                    //
                    infoPart(),
                    //
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    //
                    inputFields(),
                    //

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    //
                    registerButton(context),
                    //
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.012),
                    //
                    // Button to login if you already have an account
                    //
                    alreadyHaveAccount(),
                    //
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.012),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoPart() {
    return Center(
      child: Column(
        children: [
          Text(
            "Enregister".toUpperCase(),
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.07,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Créer votre compte",
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w200,
              fontSize: MediaQuery.of(context).size.width * 0.0385,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget inputFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //
          //name textfield
          //
          TextFormField(
            //controller
            controller: _firstnameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre prénom';
              }
              return null;
            },
            //decoration
            keyboardType: TextInputType.name,
            cursorColor: secondaryColor,
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: secondaryColor,
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
                  color: secondaryColor,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              //
              //before clicking the textfield
              //
              // label before clicking the texfield
              labelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //textfield border
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: .5),
              ),
              //
              //after clicking the textfield
              //
              //hint after clicking the textfield
              hintStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
              //floating label
              floatingLabelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //focused border
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.03),

          TextFormField(
            //controller
            controller: _lastnameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom !';
              }
              return null;
            },
            //decoration
            keyboardType: TextInputType.name,
            cursorColor: secondaryColor,
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: secondaryColor,
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
                  color: secondaryColor,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              //
              //before clicking the textfield
              //
              // label before clicking the texfield
              labelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //textfield border
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: .5),
              ),
              //
              //after clicking the textfield
              //
              //hint after clicking the textfield
              hintStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
              //floating label
              floatingLabelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //focused border
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
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
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              return null;
            },
            //decoration
            keyboardType: TextInputType.phone,
            cursorColor: secondaryColor,
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: secondaryColor,
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
                  color: secondaryColor,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              //
              //before clicking the textfield
              //
              // label before clicking the texfield
              labelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //textfield border
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: .5),
              ),
              //
              //after clicking the textfield
              //
              //hint after clicking the textfield
              hintStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
              //floating label
              floatingLabelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //focused border
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
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
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              return null;
            },
            //decoration
            keyboardType: TextInputType.emailAddress,
            cursorColor: secondaryColor,
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: secondaryColor,
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
                  color: secondaryColor,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              //
              //before clicking the textfield
              //
              // label before clicking the texfield
              labelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //textfield border
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: .5),
              ),
              //
              //after clicking the textfield
              //
              //hint after clicking the textfield
              hintStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
              //floating label
              floatingLabelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //focused border
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          //
          //password textfield
          //
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
            cursorColor: secondaryColor,
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: secondaryColor,
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
                  color: secondaryColor,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              //password eye icon with show and hide password
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: secondaryColor,
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
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //textfield border
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: .5),
              ),
              //
              //after clicking the textfield
              //
              //hint after clicking the textfield
              hintStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
              //floating label
              floatingLabelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //focused border
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre code d\'équipe';
              }
              return null;
            },
            //decoration
            keyboardType: TextInputType.text,
            cursorColor: secondaryColor,
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: secondaryColor,
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
                  color: secondaryColor,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              //
              //before clicking the textfield
              //
              // label before clicking the texfield
              labelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //textfield border
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: .5),
              ),
              //
              //after clicking the textfield
              //
              //hint after clicking the textfield
              hintStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w200,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
              //floating label
              floatingLabelStyle: GoogleFonts.montserrat(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.042,
              ),
              //focused border
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              Checkbox(
                side: const BorderSide(
                  color: secondaryColor,
                  width: 1.5,
                ),
                activeColor: primaryColor,
                checkColor: secondaryColor,
                value: _agreedToTOS,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToTOS = value!;
                  });
                },
              ),
              Row(
                children: [
                  Text(
                    'J\'accepte ',
                    style: GoogleFonts.montserrat(
                      color: secondaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: MediaQuery.of(context).size.width * 0.034,
                    ),
                  ),
                  Bounceable(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => PDFViewerFromAsset(
                          pdfAssetPath: 'assets/images/TermsAndConditions.pdf',
                        ),
                      ),
                    ),
                    child: Text(
                      'les conditions d\'utilisation',
                      style: GoogleFonts.montserrat(
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.034,
                        decoration: TextDecoration.underline,
                        decorationColor: secondaryColor,
                        decorationThickness: 2,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget registerButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (!_agreedToTOS) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Veuillez accepter les conditions d\'utilisation.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            // Clear previous notifications
            Provider.of<NotificationProvider>(context, listen: false)
                .clearNotifications();
            registerUser(context);
          }
        }
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

  Widget alreadyHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte ?',
          style: GoogleFonts.montserrat(
            color: secondaryColor,
            fontWeight: FontWeight.w200,
            fontSize: MediaQuery.of(context).size.width * 0.032,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/login", (route) => false);
          },
          child: Text(
            'Connectez-vous',
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.032,
              decoration: TextDecoration.underline,
              decorationColor: secondaryColor,
              decorationThickness: 2,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
        )
      ],
    );
  }
}
