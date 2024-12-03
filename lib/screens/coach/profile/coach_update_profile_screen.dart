import 'package:flutter/material.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/provider/coach_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CoachUpdateProfileScreen extends StatefulWidget {
  final User user;
  const CoachUpdateProfileScreen({super.key, required this.user});

  @override
  State<CoachUpdateProfileScreen> createState() =>
      _CoachUpdateProfileScreenState();
}

class _CoachUpdateProfileScreenState extends State<CoachUpdateProfileScreen> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _dateNaissanceController;
  final bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _telephoneController = TextEditingController();
    _adresseController = TextEditingController();
    _dateNaissanceController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final coachProvider = Provider.of<CoachProvider>(context, listen: false);
      await coachProvider.fetchCoach();
      if (mounted) {
        _initializeTextControllers(coachProvider.user);
        setState(() {});
      }
    });
  }

  void _initializeTextControllers(User? user) {
    _firstnameController = TextEditingController(text: user?.firstname ?? '');
    _lastnameController = TextEditingController(text: user?.lastname ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _telephoneController = TextEditingController(text: user?.telephone ?? '');
    _adresseController = TextEditingController(text: user?.adresse ?? '');
    _dateNaissanceController =
        TextEditingController(text: user?.dateNaissance ?? '');
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final coachProvider = Provider.of<CoachProvider>(context, listen: false);
      final currentUser = coachProvider.user;

      if (currentUser != null) {
        Map<String, dynamic> updatedFields = {
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'email': _emailController.text,
          'telephone': _telephoneController.text,
          'adresse': _adresseController.text,
          'dateNaissance': _dateNaissanceController.text,
        };

        // Show password confirmation dialog
        // final password = await showPasswordConfirmationDialog();
        // if (password != null) {
        //   final isConfirmed =
        //       await coachProvider.confirmPassword(currentUser.email, password);
        //   if (isConfirmed) {
        await coachProvider.updateCoachProfile(updatedFields);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Compte mis à jour avec succès'),
          duration: Duration(seconds: 1),
        ));
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.of(context).pop());
        //   //await coachProvider.fetchCoach();
        //} else {
        //ScaffoldMessenger.of(context).showSnackBar(
        //  const SnackBar(content: Text('Mot de passe incorrect')));
        //}
        //}
      }
    }
  }

  Future<String?> showPasswordConfirmationDialog() async {
    TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer votre mot de passe',
            style: GoogleFonts.montserrat(
              color: black,
              fontWeight: FontWeight.w700,
              fontSize: MediaQuery.of(context).size.width * 0.040,
            ),
          ),
          content: TextFormField(
            //controller
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre password';
              }
              return null;
            },
            //decoration
            obscureText: _obscurePassword,
            cursorColor: black,
            style: GoogleFonts.montserrat(
              color: black,
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.038,
              decorationColor: black,
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
                  color: black,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
              ),

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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: GoogleFonts.montserrat(
                  color: red,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width * 0.040,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
              child: Text(
                'Confirmer',
                style: GoogleFonts.montserrat(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width * 0.040,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Modifier Profile',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              informationFields(context),

              updateAccountButton(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              //supprimer compte
              deleteAccountButton(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  MaterialButton deleteAccountButton(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        // Confirm deletion of the user
        bool? confirmDeletion = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Confirmer la suppression',
                style: GoogleFonts.montserrat(
                  color: black,
                  fontWeight: FontWeight.w700,
                  fontSize: MediaQuery.of(context).size.width * 0.040,
                ),
              ),
              content: Text(
                'Voulez-vous vraiment supprimer votre compte ?',
                style: GoogleFonts.montserrat(
                  color: black,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.038,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.montserrat(
                      color: red,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.040,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    'Supprimer',
                    style: GoogleFonts.montserrat(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.040,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirmDeletion == true) {
          try {
            await _authService.deleteProfile();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Compte supprimé avec succès')),
            );

            // Navigate to login screen
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacementNamed('/login');
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Échec de la suppression du compte')),
            );
          }
        }
      },
      // Style and other button properties
      height: MediaQuery.of(context).size.height * 0.054,
      minWidth: MediaQuery.of(context).size.width * 0.65,
      color: Colors.red[900],
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.012,
        horizontal: MediaQuery.of(context).size.width * 0.13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Text(
        "Supprimer compte".toUpperCase(),
        style: GoogleFonts.montserrat(
          color: white,
          fontWeight: FontWeight.w700,
          fontSize: MediaQuery.of(context).size.width * 0.047,
        ),
      ),
    );
  }

  MaterialButton updateAccountButton(BuildContext context) {
    return MaterialButton(
      onPressed: _updateProfile,
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

  Column informationFields(BuildContext context) {
    return Column(
      children: [
        //prénom
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
          cursorColor: black,
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.038,
            decorationColor: black,
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
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
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

        //nom
        TextFormField(
          //controller
          controller: _lastnameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            return null;
          },
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
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
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

        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

        //email
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
          cursorColor: black,
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.038,
            decorationColor: black,
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
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
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

        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

        //telephone
        TextFormField(
          //controller
          controller: _telephoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro de téléphone';
            }
            return null;
          },
          //decoration
          keyboardType: TextInputType.phone,
          cursorColor: black,
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.038,
            decorationColor: black,
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
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
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

        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

        //adresse
        TextFormField(
          //controller
          controller: _adresseController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre addresse';
            }
            return null;
          },
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
            labelText: "Adresse",
            hintText: "Entez votre adresse",
            //person icon
            prefixIcon: Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.052,
                left: MediaQuery.of(context).size.width * 0.027,
              ),
              child: Icon(
                Icons.pin_drop,
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
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

        //date de naissance
        TextFormField(
          //controller
          controller: _dateNaissanceController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre date de naissance';
            }
            return null;
          },
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
            labelText: "Date de naissance",
            hintText: "Date de naissance: YYYY-MM-DD",
            //person icon
            prefixIcon: Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.052,
                left: MediaQuery.of(context).size.width * 0.027,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
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
        TextFormField(
          //controller
          controller: _passwordController,
          //decoration
          obscureText: _obscurePassword,
          cursorColor: black,
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.038,
            decorationColor: black,
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
                color: black,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
            ),

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
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }
}
