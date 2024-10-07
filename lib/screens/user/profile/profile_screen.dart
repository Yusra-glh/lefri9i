import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gark_academy/models/payment_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/screens/user/events/user_evaluation_screen.dart';
import 'package:gark_academy/screens/user/profile/connect_account_screen.dart';
import 'package:gark_academy/screens/user/profile/medical_info_update_screen.dart';
import 'package:gark_academy/screens/user/profile/profile_update_screen.dart';
import 'package:gark_academy/screens/widgets/statistics_expandable_widget.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/services/payment_service.dart';
import 'package:gark_academy/services/provider/member_provider.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:gark_academy/widgets/tab_item_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final PaymentService _paymentService = PaymentService();

  late TabController tabController;

  User? user;
  List<Payment> paymentHistoryList = [];
  List<Map<String, dynamic>> accountsList = [];
  bool isLoading = true;
  String? errorMessage;
  int selectedIndex = 0;
  String? bannerColor;
  bool isExpanded = true;

  //user infos
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _equipeController;
  late TextEditingController _adresseController;
  late TextEditingController _nationaliteController;
  late TextEditingController _niveauScolaireController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
    getPaymentInfos();
  }

  void _initializeControllers() {
    //tab controller
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {
          selectedIndex = tabController.index;
        });
      }
    });
    //general info controllers
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _emailController = TextEditingController();
    _telephoneController = TextEditingController();
    _adresseController = TextEditingController();
    _nationaliteController = TextEditingController();
    _dateNaissanceController = TextEditingController();
    _niveauScolaireController = TextEditingController();
    _equipeController = TextEditingController();
  }

  Future<void> _fetchUserData() async {
    try {
      final userProvider = Provider.of<MemberProvider>(context, listen: false);
      await userProvider.fetchUser();
      final usersList = await getUsersList();
      setState(() {
        user = userProvider.user;
        if (user != null) {
          _initializeTextControllers(user!);
        }
        isLoading = false;
        accountsList = usersList;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data';
      });
    }
  }

  void _initializeTextControllers(User user) {
    //DateTime dateFin = DateFormat('yyyy-MM-dd').parse(latestPayment.dateFin);
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
    _adresseController.text = user.adresse ?? 'Ajouter votre adresse';
    _nationaliteController.text =
        user.nationalite ?? 'Ajouter votre nationalité';
    _niveauScolaireController.text =
        user.niveauScolaire ?? 'Ajouter votre niveau scolaire';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  void getPaymentInfos() async {
    try {
      List<Payment> paymentHistory = await _paymentService.getPaymentHistory();
      setState(() {
        // Sort the paymentHistory list by id in descending order
        paymentHistory.sort((a, b) => b.id.compareTo(a.id));
        paymentHistoryList = paymentHistory;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void checkPaymentStatus() async {
    try {
      String? status = await _paymentService.checkPaymentStatus();
      setState(() {
        bannerColor = status;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  login(String email, String password) async {
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
  }

  @override
  void dispose() {
    tabController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _equipeController.dispose();
    _adresseController.dispose();
    _nationaliteController.dispose();
    _dateNaissanceController.dispose();
    _niveauScolaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Profil',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
        leading: BackButton(
          color: black,
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/homeUser");
          },
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  buildSelectAccountPopup(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Colors.grey[300], // Light grey color for the background
                  ),
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.height * 0.018,
                  ),
                  child: SvgPicture.asset(
                    "assets/icones/add.svg",
                    // ignore: deprecated_member_use
                    color: black,
                    width: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
              ),
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
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: black,
            ))
          : Column(
              children: [
                //SizedBox(height: MediaQuery.of(context).size.height * 0.036),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.27,
                        width: MediaQuery.of(context).size.width * 0.27,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: user?.photo ??
                                'https://ui-avatars.com/api/?name=${user?.firstname}+${user?.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150',
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
                            "Bonjour, ${user?.firstname} ",
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
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                top: 0,
                                left: MediaQuery.of(context).size.width * 0.027,
                                right:
                                    MediaQuery.of(context).size.width * 0.027,
                                bottom: 0,
                              ),
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.01,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TabBar(
                                controller: tabController,
                                // this is to remove the accent color when clicking on the tab
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                onTap: _onTabTapped,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  color: Colors.black,
                                ),
                                indicatorColor: Colors.black,
                                dividerColor: Colors.transparent,
                                tabs: [
                                  EventTabItemIcon(
                                    icon: SvgPicture.asset(
                                      "assets/icones/info.svg",
                                      color: Colors.grey,
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                    ),
                                    isSelected: selectedIndex == 0,
                                  ),
                                  EventTabItemIcon(
                                    icon: SvgPicture.asset(
                                      "assets/icones/medical.svg",
                                      color: Colors.grey,
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                    ),
                                    isSelected: selectedIndex == 1,
                                  ),
                                  EventTabItemIcon(
                                    icon: SvgPicture.asset(
                                      "assets/icones/money.svg",
                                      color: Colors.grey,
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                    ),
                                    isSelected: selectedIndex == 2,
                                  ),
                                  EventTabItemIcon(
                                    icon: SvgPicture.asset(
                                      "assets/icones/note.svg",
                                      color: Colors.grey,
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                    ),
                                    isSelected: selectedIndex == 3,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            SingleChildScrollView(
                              child: SizedBox(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: TabBarView(
                                  controller: tabController,
                                  children: [
                                    buildGeneralInfo(context),
                                    buildMedicalInfo(context),
                                    buildPaymentInfo(context),
                                    buildInfoSportiveInfo(context),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget buildInfoSportiveInfo(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.height * 0.024,
            ),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.024,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: secondaryColorLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    "Assiduité ",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.montserrat(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${user?.informationsSportives?.totalPresence ?? 0} présences ",
                      style: GoogleFonts.montserrat(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text(
                      "${(user?.informationsSportives?.totalSession ?? 0) > 0 ? (user?.informationsSportives?.totalSession ?? 0) - (user?.informationsSportives?.totalPresence ?? 0) : 0} absences",
                      style: GoogleFonts.montserrat(
                        color: red,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.height * 0.024,
            ),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.024,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: secondaryColorLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    "Evaluations ",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.montserrat(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ),
                Column(
                  children: user?.informationsSportives?.performances
                          ?.map((test) {
                        return GestureDetector(
                          onTap: () {
                            if (test.testId != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserEvaluationScreen(
                                    attendanceId: test.testId!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icones/note.svg",
                                  color: Colors.grey,
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  test.evalName ?? "test",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.108),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMedicalInfo(BuildContext context) {
    return Padding(
      // padding: EdgeInsets.symmetric(
      //   horizontal: MediaQuery.of(context).size.width * 0.04,
      //   vertical: MediaQuery.of(context).size.height * 0.02,
      // ),
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.04,
        left: MediaQuery.of(context).size.width * 0.04,
        top: MediaQuery.of(context).size.height * 0.02,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.024,
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.024,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: secondaryColorLight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Condition Médicale",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0385,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.006),
                        if (user?.conditionMedicale?.isNotEmpty ?? false)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      0.006,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Condition Médicale: ",
                                        style: GoogleFonts.montserrat(
                                          color: grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.0315,
                                        ),
                                      ),
                                      TextSpan(
                                        text: user!.conditionMedicale,
                                        style: GoogleFonts.montserrat(
                                          color: black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.036,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            "Il n'y a pas d'informations sur la condition médicale.",
                            style: GoogleFonts.montserrat(
                              color: grey,
                              fontWeight: FontWeight.w300,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.024,
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.024,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: secondaryColorLight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Allergies",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0385,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.006),
                        if (user?.allergies?.isNotEmpty ?? false)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: user!.allergies!.map((allergy) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      0.006,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Allergie: ",
                                        style: GoogleFonts.montserrat(
                                          color: grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.0315,
                                        ),
                                      ),
                                      TextSpan(
                                        text: allergy,
                                        style: GoogleFonts.montserrat(
                                          color: black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.036,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text(
                            "Il n'y a pas d'informations sur les allergies.",
                            style: GoogleFonts.montserrat(
                              color: grey,
                              fontWeight: FontWeight.w300,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.024,
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.024,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: secondaryColorLight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Médicaments Actuels",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0385,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.006),
                        if (user?.medicamentActuel?.isNotEmpty ?? false)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: user!.medicamentActuel!.map((medicine) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      0.006,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Médicament: ",
                                        style: GoogleFonts.montserrat(
                                          color: grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.0315,
                                        ),
                                      ),
                                      TextSpan(
                                        text: medicine,
                                        style: GoogleFonts.montserrat(
                                          color: black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.036,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text(
                            "Il n'y a pas d'informations sur les médicaments actuels.",
                            style: GoogleFonts.montserrat(
                              color: grey,
                              fontWeight: FontWeight.w300,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.024,
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.024,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: secondaryColorLight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Médicaments Passés",
                          style: GoogleFonts.montserrat(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0385,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.006),
                        if (user?.medicamentPasses?.isNotEmpty ?? false)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: user!.medicamentPasses!.map((medicine) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      0.006,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Médicament: ",
                                        style: GoogleFonts.montserrat(
                                          color: grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.0315,
                                        ),
                                      ),
                                      TextSpan(
                                        text: medicine,
                                        style: GoogleFonts.montserrat(
                                          color: black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.036,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text(
                            "Il n'y a pas d'informations sur les médicaments passés.",
                            style: GoogleFonts.montserrat(
                              color: grey,
                              fontWeight: FontWeight.w300,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0315,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MedicalInfoUpdateScreen(),
                    ),
                  );
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
                  "Modifier".toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: MediaQuery.of(context).size.width * 0.047,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentInfo(BuildContext context) {
    return Column(
      children: [
        //buildBanner(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Expanded(
          child: ListView.builder(
            itemCount: paymentHistoryList.length,
            itemBuilder: (context, index) {
              return paymentCard(paymentHistoryList[index], context);
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget paymentCard(Payment payment, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.height * 0.024,
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.024,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: secondaryColorLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Paiement",
                  style: GoogleFonts.montserrat(
                    color: black,
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Date debut paiement: ",
                        style: GoogleFonts.montserrat(
                          color: grey,
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.0315,
                        ),
                      ),
                      TextSpan(
                        text: payment.dateDebut,
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Date fin paiement: ",
                        style: GoogleFonts.montserrat(
                          color: grey,
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.0315,
                        ),
                      ),
                      TextSpan(
                        text: payment.dateFin,
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Date de paiement: ",
                        style: GoogleFonts.montserrat(
                          color: grey,
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.0315,
                        ),
                      ),
                      TextSpan(
                        text: payment.datePaiement ?? "Non_Payé",
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Status: ",
                        style: GoogleFonts.montserrat(
                          color: grey,
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.0315,
                        ),
                      ),
                      TextSpan(
                        text: payment.statutAdherent,
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Montant payé: ",
                        style: GoogleFonts.montserrat(
                          color: grey,
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.0315,
                        ),
                      ),
                      TextSpan(
                        text: "${payment.montant} DT",
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Montant restant: ",
                        style: GoogleFonts.montserrat(
                          color: grey,
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.0315,
                        ),
                      ),
                      TextSpan(
                        text: "${payment.reste} DT",
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGeneralInfo(BuildContext context) {
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
                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _nationaliteController,
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
                        labelText: "Nationalité",

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

                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _adresseController,
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
                        labelText: "Adresse",

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

                    TextFormField(
                      enabled: false,
                      //controller
                      controller: _niveauScolaireController,
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
                        labelText: "Niveau scolaire",

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
                              builder: (context) =>
                                  ProfileUpdateScreen(user: user!),
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

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                ),
    );
  }

  Future<List<Map<String, dynamic>>> getUsersList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> usersList = prefs.getStringList('usersList') ?? [];
    List<Map<String, dynamic>> usersListMap = usersList.map((userJson) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }).toList();

    return usersListMap;
  }

  Future<dynamic> buildSelectAccountPopup(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(25),
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.012,
              left: MediaQuery.of(context).size.width * 0.052,
              right: MediaQuery.of(context).size.width * 0.052,
              bottom: MediaQuery.of(context).size.height * 0.018,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  thickness: 3,
                  color: primaryColor,
                  indent: MediaQuery.of(context).size.width * 0.38,
                  endIndent: MediaQuery.of(context).size.width * 0.38,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Column(
                  children: accountsList.map((account) {
                    return GestureDetector(
                        onTap: () {
                          login(account["email"], account["password"]);
                        },
                        child: accountCard(account, context));
                  }).toList(),
                ),
                // ListView.builder(
                //   itemCount: accountsList.length,
                //   itemBuilder: (context, index) {
                //     final account = accountsList[index];
                //     return accountCard(account, context);
                //   },
                // ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Divider(
                  thickness: .5,
                  color: black.withOpacity(.2),
                  indent: MediaQuery.of(context).size.width * 0.12,
                  endIndent: MediaQuery.of(context).size.width * 0.12,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/add-account");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.0385,
                        ),
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.0315,
                        ),
                        decoration: BoxDecoration(
                          color: black,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: SvgPicture.asset(
                          "assets/icones/add.svg",
                          // ignore: deprecated_member_use
                          color: white,
                          width: MediaQuery.of(context).size.width * 0.027,
                        ),
                      ),
                      Text(
                        "Ajouter un autre compte",
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.0385,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConnectUserScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.0385,
                        ),
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.0315,
                        ),
                        decoration: BoxDecoration(
                          color: black,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: SvgPicture.asset(
                          "assets/icones/add.svg",
                          // ignore: deprecated_member_use
                          color: white,
                          width: MediaQuery.of(context).size.width * 0.027,
                        ),
                      ),
                      Text(
                        "Se connecter",
                        style: GoogleFonts.montserrat(
                          color: black,
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.0385,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.045),
                confirmButton(context),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget accountCard(Map<String, dynamic> account, BuildContext context) {
  return Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).size.height * 0.012,
      left: MediaQuery.of(context).size.width * 0.027,
      right: MediaQuery.of(context).size.width * 0.027,
      bottom: MediaQuery.of(context).size.height * 0.012,
    ),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(50),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                account['academyLogo'],
                width: MediaQuery.of(context).size.width * 0.125,
                height: MediaQuery.of(context).size.height * 0.06,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04),
            Text(
              account['userName'],
              style: GoogleFonts.raleway(
                color: black,
                fontWeight: FontWeight.w500,
                fontSize: MediaQuery.of(context).size.width * 0.052,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

MaterialButton confirmButton(BuildContext context) {
  return MaterialButton(
    onPressed: () {
      //logic here
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
      "confirmer".toUpperCase(),
      style: GoogleFonts.montserrat(
        color: white,
        fontWeight: FontWeight.w700,
        fontSize: MediaQuery.of(context).size.width * 0.047,
      ),
    ),
  );
}
