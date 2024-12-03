import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/screens/coach/profile/coach_update_profile_screen.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/provider/coach_provider.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = true;
  String? errorMessage;

  //coach infos
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _equipeController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCoachData();
    });
  }

  void _initializeControllers() {
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _emailController = TextEditingController();
    _telephoneController = TextEditingController();
    _dateNaissanceController = TextEditingController();
    _equipeController = TextEditingController();
  }

  Future<void> _fetchCoachData() async {
    try {
      final coachProvider = Provider.of<CoachProvider>(context, listen: false);
      await coachProvider.fetchCoach();
      setState(() {
        user = coachProvider.user;
        if (user != null) {
          _initializeTextControllers(user!);
        }
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data';
      });
    }
  }

  void _initializeTextControllers(User user) {
    _firstnameController.text = user.firstname;
    _lastnameController.text = user.lastname;
    _emailController.text = user.email;
    _telephoneController.text =
        user.telephone ?? 'Ajouter votre numéro de téléphone';
    _dateNaissanceController.text =
        user.dateNaissance ?? 'Ajouter votre date de naissance';
    _equipeController.text = (user.equipes?.isNotEmpty == true
        ? user.equipes![0].nom
        : 'Non affecté à une équipe')!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCoachData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoachProvider>();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
        leading: BackButton(
          color: black,
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/homeCoach");
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _authService.logout();
              // Clear previous notifications
              Provider.of<NotificationProvider>(context, listen: false)
                  .clearNotifications();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.045),
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.018,
              ),
              child: SvgPicture.asset(
                "assets/icones/logout.svg",
                // ignore: deprecated_member_use
                color: black,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: black,
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.036),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.27,
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://ui-avatars.com/api/?name=${provider.user?.firstname}+${provider.user?.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(color: black),
                              //errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.012),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bonjour, ${provider.user?.firstname} ${provider.user?.lastname}",
                              style: GoogleFonts.raleway(
                                color: black,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.052,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.036),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 0,
                            left: MediaQuery.of(context).size.width * 0.052,
                            right: MediaQuery.of(context).size.width * 0.052,
                            bottom: 0,
                          ),
                          child: buildGeneralInfo(context),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget buildGeneralInfo(BuildContext context) {
    final provider = context.watch<CoachProvider>();
    return SingleChildScrollView(
      child: isLoading
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Center(
                child: CircularProgressIndicator(
                  color: black,
                ),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    //prenom
                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _firstnameController,

                      validator: (value) {
                        return null;
                      },

                      //decoration
                      keyboardType: TextInputType.name,
                      cursorColor: secondaryColor,
                      style: GoogleFonts.montserrat(
                        color: black,
                        height: 2,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: secondaryColor,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.only(5),
                        labelText: "Prénom",
                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        // floatingLabelStyle: GoogleFonts.raleway(
                        //   color: secondaryColor,
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                        floatingLabelStyle: GoogleFonts.raleway(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.046,
                          decoration: TextDecoration.underline,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    //Nom
                    TextFormField(
                      enabled: false,
                      controller: _lastnameController,

                      //controller
                      validator: (value) {
                        return null;
                      },

                      //decoration
                      keyboardType: TextInputType.name,
                      cursorColor: secondaryColor,
                      style: GoogleFonts.montserrat(
                        color: black,
                        height: 2,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: secondaryColor,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.only(5),
                        labelText: "Nom",
                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        // floatingLabelStyle: GoogleFonts.raleway(
                        //   color: secondaryColor,
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                        floatingLabelStyle: GoogleFonts.raleway(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.046,
                          decoration: TextDecoration.underline,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    //
                    //phone textfield
                    //
                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _telephoneController,
                      validator: (value) {
                        return null;
                      },
                      //decoration
                      keyboardType: TextInputType.phone,
                      cursorColor: secondaryColor,
                      style: GoogleFonts.montserrat(
                        color: black,
                        height: 2,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: secondaryColor,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText: "Téléphone",

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
                          borderSide:
                              BorderSide(color: secondaryColor, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        // floatingLabelStyle: GoogleFonts.raleway(
                        //   color: secondaryColor,
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                        floatingLabelStyle: GoogleFonts.raleway(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.046,
                          decoration: TextDecoration.underline,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    //
                    //email textfield
                    //
                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _emailController,
                      validator: (value) {
                        return null;
                      },
                      //decoration
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: secondaryColor,

                      style: GoogleFonts.montserrat(
                        height: 2,
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: secondaryColor,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText: "Email",

                        //
                        //before clicking the textfield
                        //
                        // label before clicking the textfield
                        labelStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        // floatingLabelStyle: GoogleFonts.raleway(
                        //   color: secondaryColor,
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                        floatingLabelStyle: GoogleFonts.raleway(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.046,
                          decoration: TextDecoration.underline,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    //
                    //birthday textfield
                    //
                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _dateNaissanceController,
                      validator: (value) {
                        return null;
                      },
                      //decoration
                      keyboardType: TextInputType.datetime,
                      cursorColor: secondaryColor,
                      style: GoogleFonts.montserrat(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.036,
                        decorationColor: secondaryColor,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText: "Date de naissance",

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
                          borderSide:
                              BorderSide(color: secondaryColor, width: .5),
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
                        // floatingLabelStyle: GoogleFonts.montserrat(
                        //   color: secondaryColor,
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                        floatingLabelStyle: GoogleFonts.raleway(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.046,
                          decoration: TextDecoration.underline,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    //
                    //team name textfield
                    //
                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _equipeController,
                      validator: (value) {
                        return null;
                      },
                      //decoration
                      keyboardType: TextInputType.number,
                      cursorColor: secondaryColor,
                      style: GoogleFonts.montserrat(
                        height: 2,
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        decorationColor: secondaryColor,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: const EdgeInsets.all(5),
                        labelText: "Nom d'équipe",
                        hintText: "Nom d'équipe",
                        //
                        //before clicking the textfield
                        //
                        // label before clicking the texfield
                        labelStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                        //textfield border
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: .5),
                        ),
                        //
                        //after clicking the textfield
                        //
                        //hint after clicking the textfield
                        hintStyle: GoogleFonts.raleway(
                          color: secondaryColor,
                          fontWeight: FontWeight.w200,
                          fontSize: MediaQuery.of(context).size.width * 0.038,
                        ),
                        //floating label
                        // floatingLabelStyle: GoogleFonts.raleway(
                        //   color: secondaryColor,
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                        floatingLabelStyle: GoogleFonts.raleway(
                          color: black,
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width * 0.046,
                          decoration: TextDecoration.underline,
                        ),
                        //focused border
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: secondaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035),
                    //button modifier profile
                    Center(
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoachUpdateProfileScreen(
                                  user: provider.user!),
                            ),
                          ).then((updatedUser) {
                            if (updatedUser != null) {
                              setState(() {
                                user = updatedUser;
                              });
                            }
                          });
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
                          "Modifier Profile".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.of(context).size.width * 0.047,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  ],
                ),
    );
  }
}
