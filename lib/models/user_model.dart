import 'package:gark_academy/models/equipe_model.dart';
import 'package:gark_academy/models/informations_sportives_model.dart';

class User {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? password;
  final String role;
  final String? statutAdherent;
  final String? roleName;
  final String? dateNaissance;
  final String? adresse;
  final String? telephone;
  final String? telephone2;
  final String? nationalite;
  final String? academieName;
  final String? photo;
  final String? niveauScolaire;
  final List<String>? equipeIds;
  final Map<String, dynamic>? informationParent;
  final String? conditionMedicale;
  final List<String>? allergies;
  final List<String>? medicamentActuel;
  final List<String>? medicamentPasses;
  final List<Equipe>? equipes;
  final InformationsSportives? informationsSportives;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.password,
    required this.role,
    this.adresse,
    this.telephone,
    this.telephone2,
    this.dateNaissance,
    this.nationalite,
    this.photo,
    this.niveauScolaire,
    this.equipeIds,
    this.informationParent,
    this.conditionMedicale,
    this.allergies,
    this.medicamentActuel,
    this.medicamentPasses,
    this.equipes,
    this.statutAdherent,
    this.roleName,
    this.academieName,
    this.informationsSportives,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      telephone2: json['telephone2'],
      dateNaissance: json['dateNaissance'],
      nationalite: json['nationalite'],
      photo: json['photo'],
      niveauScolaire: json['niveauScolaire'],
      equipeIds:
          json['equipeIds'] != null ? List<String>.from(json['equipeIds']) : [],
      informationParent: json['informationParent'],
      conditionMedicale: json['conditionMedicale'],
      allergies:
          json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      medicamentActuel: json['medicamentActuel'] != null
          ? List<String>.from(json['medicamentActuel'])
          : [],
      medicamentPasses: json['medicamentPasses'] != null
          ? List<String>.from(json['medicamentPasses'])
          : [],
      equipes: json['equipes'] != null
          ? List<Equipe>.from(
              json['equipes'].map((equipe) => Equipe.fromJson(equipe)))
          : [],
      statutAdherent: json['statutAdherent'],
      roleName: json['roleName'],
      academieName: json['academieName'],
      informationsSportives: json['informationSportives'] != null
          ? InformationsSportives.fromJson(json['informationSportives'])
          : null,
    );
  }
}
