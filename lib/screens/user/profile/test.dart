import 'package:flutter/material.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final User user;

  const ProfileUpdateScreen({super.key, required this.user});

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final MemberService _userService = MemberService();
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _nationaliteController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _niveauScolaireController;

  @override
  void initState() {
    super.initState();
    print("photo: ${widget.user.photo}");
    _firstnameController = TextEditingController(text: widget.user.firstname);
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _emailController = TextEditingController(text: widget.user.email);
    _telephoneController = TextEditingController(text: widget.user.telephone);
    _adresseController = TextEditingController(text: widget.user.adresse);
    _nationaliteController =
        TextEditingController(text: widget.user.nationalite);
    _dateNaissanceController =
        TextEditingController(text: widget.user.dateNaissance);
    _niveauScolaireController =
        TextEditingController(text: widget.user.niveauScolaire);
  }

  final bool _obscurePassword = true;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _nationaliteController.dispose();
    _dateNaissanceController.dispose();
    _niveauScolaireController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Collect only modified fields
      Map<String, dynamic> updatedFields = {
        'id': widget.user.id,
        'firstname': _firstnameController.text,
        'lastname': _lastnameController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'adresse': _adresseController.text,
        'nationalite': _nationaliteController.text,
        'dateNaissance': _dateNaissanceController.text,
        'niveauScolaire': _niveauScolaireController.text,
        'photo': widget.user.photo,
      };

      // final password = await showPasswordConfirmationDialog();
      // if (password != null) {
      //   final response =
      //       await _userService.confirmPassword(widget.user.email, password);
      //   if (response.statusCode == 200) {
      await _userService.updateMemberProfile(widget.user, updatedFields);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Compte mis à jour avec succès'),
        duration: Duration(seconds: 1),
      ));
      Future.delayed(
          const Duration(seconds: 1), () => Navigator.of(context).pop());
      //   } else {
      //     print('Password confirmation failed: ${response.data}');
      //     ScaffoldMessenger.of(context)
      //         .showSnackBar(SnackBar(content: Text('Mot de passe incorrect')));
      //   }
      // }
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

              //nationalite
              TextFormField(
                //controller
                controller: _nationaliteController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nationalité';
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
                  labelText: "Nationalité",
                  hintText: "Entez votre nationalité",
                  //person icon
                  prefixIcon: Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.052,
                      left: MediaQuery.of(context).size.width * 0.027,
                    ),
                    child: Icon(
                      Icons.flag_rounded,
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

              //niveau scolaire
              TextFormField(
                //controller
                controller: _niveauScolaireController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre niveau scolaire';
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
                  labelText: "Niveau scolaire",
                  hintText: "Entez votre niveau scolaire",
                  //person icon
                  prefixIcon: Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.052,
                      left: MediaQuery.of(context).size.width * 0.027,
                    ),
                    child: Icon(
                      Icons.school,
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

              MaterialButton(
                onPressed: _updateProfile,
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
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              MaterialButton(
                onPressed: () async {
                  final Uri url = Uri.parse(
                      'https://docs.google.com/forms/d/e/1FAIpQLSePH5RsegP476OGWpow3uevpTBS2g87yqJA3pLmGVAaxbTGRw/viewform?usp=sf_link');
                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    print('Could not launch $url');
                  }
                  _authService.logout();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacementNamed('/login');
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
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
