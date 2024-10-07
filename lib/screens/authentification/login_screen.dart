import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  Colors.black.withOpacity(0.65), BlendMode.darken),
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
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.096),
                    inputFields(),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.240),
                    //
                    loginButton(context),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.012),
                    //
                    // Button to register if you don't have an account
                    //
                    notHaveAccount(context),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Center infoPart() {
    return Center(
      child: Column(
        children: [
          Text(
            "Bienvenue".toUpperCase(),
            style: GoogleFonts.montserrat(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.07,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Connectez-vous à votre compte",
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

  Form inputFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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

          SizedBox(height: MediaQuery.of(context).size.height * 0.048),
          //
          //password textfield
          //
          TextFormField(
            //controller
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre password';
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
        ],
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        if (_isButtonDisabled) {
          return;
        } else if (_formKey.currentState!.validate()) {
          final email = _emailController.text;
          final password = _passwordController.text;
          final notifProvider =
              Provider.of<NotificationProvider>(context, listen: false);
          final fcmToken = await notifProvider.getFcmToken();
          // // Clear previous notifications
          // Provider.of<NotificationProvider>(context, listen: false)
          //     .clearNotifications();
          log('-----------------fcm token: $fcmToken');

          final response =
              await _authService.loginUser(email, password, fcmToken);

          if (response.statusCode == 200) {
            // Redirect based on user role
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? email = prefs.getString('userEmail');
            if (email != null) {
              notifProvider.connectWebSocket(email);
            }
            String? userRole = prefs.getString('userRole');

            if (userRole == 'ADHERENT') {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, "/homeUser");
            } else if (userRole == 'ENTRAINEUR') {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, "/homeCoach");
            }
          } else if (response.statusCode == 401) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Votre compte est bloqué. Contactez un manager.')),
            );
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Email ou mot de passe incorrecte.')),
            );
          }

          // Disable the button to prevent multiple clicks
          if (mounted) {
            setState(() {
              _isButtonDisabled = true;
            });
          }
          Future.delayed(const Duration(milliseconds: 3000), () {
            if (mounted) {
              setState(() {
                _isButtonDisabled = false;
              });
            }
          });
        }
      },
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
        "Connecter".toUpperCase(),
        style: GoogleFonts.montserrat(
          color: white,
          fontWeight: FontWeight.w700,
          fontSize: MediaQuery.of(context).size.width * 0.047,
        ),
      ),
    );
  }

  Row notHaveAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous n\'avez pas de compte ?',
          style: GoogleFonts.montserrat(
            color: secondaryColor,
            fontWeight: FontWeight.w200,
            fontSize: MediaQuery.of(context).size.width * 0.032,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, "/register");
          },
          child: Text(
            'Inscrivez-vous',
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
