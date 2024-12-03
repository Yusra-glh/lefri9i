import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectUserScreen extends StatefulWidget {
  const ConnectUserScreen({super.key});

  @override
  State<ConnectUserScreen> createState() => _ConnectUserScreenState();
}

class _ConnectUserScreenState extends State<ConnectUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  Future<void> login(BuildContext context) async {
    // if (_isButtonDisabled) {
    //   return;
    // } else
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final notifProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final fcmToken = await notifProvider.getFcmToken();
      // // Clear previous notifications
      // Provider.of<NotificationProvider>(context, listen: false)
      //     .clearNotifications();
      log('-----------------fcm token: $fcmToken');

      final response = await _authService.loginUser(email, password, fcmToken);

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
              content: Text('Votre compte est bloqué. Contactez un manager.')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou mot de passe incorrecte.')),
        );
      }

      // Disable the button to prevent multiple clicks
      if (mounted) {
        setState(() {
          //_isButtonDisabled = true;
        });
      }
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          setState(() {
            //_isButtonDisabled = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: darkgrey,
        title: Text(
          'Se connecter',
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
        login(context);
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
