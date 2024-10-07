import 'package:gark_academy/models/user_model.dart';

class Academy {
  final int id;
  final String nom;
  final String? type;
  final double? fraisAdhesion;
  final String logo;
  final String? backgroundImage;
  final String? etat;
  final String? description;
  final bool? isArchived;
  final String? rue;
  final String? ville;
  final String? codePostal;
  final String? pays;
  final int? managerId;
  final User? manager;

  Academy({
    required this.id,
    required this.nom,
    this.type,
    this.fraisAdhesion,
    required this.logo,
    this.backgroundImage,
    this.etat,
    this.description,
    this.isArchived,
    this.rue,
    this.ville,
    this.codePostal,
    this.pays,
    this.managerId,
    this.manager,
  });

  factory Academy.fromJson(Map<String, dynamic> json) {
    return Academy(
      id: json['id'],
      nom: json['nom'],
      type: json['type'],
      fraisAdhesion: json['fraisAdhesion'],
      logo: json['logo'],
      backgroundImage: json['backgroundImage'],
      etat: json['etat'],
      description: json['description'],
      isArchived: json['isArchived'],
      rue: json['rue'],
      ville: json['ville'],
      codePostal: json['codePostal'],
      pays: json['pays'],
      managerId: json['managerId'],
      manager: json['manager'] != null ? User.fromJson(json['manager']) : null,
    );
  }
}
