import 'package:gark_academy/models/discipline_model.dart';

class Equipe {
  final int? id;
  final String? nom;
  final String? genre;
  final String? groupeAge;
  final String couleur;
  final String codeEquipe;
  final String logo;
  final List<Discipline>? discipline;
  final List<dynamic>? adherents;
  final List<dynamic>? entraineurs;
  final List<dynamic>? convocations;

  Equipe({
    required this.id,
    required this.nom,
    required this.genre,
    required this.groupeAge,
    required this.couleur,
    required this.codeEquipe,
    required this.logo,
    this.discipline,
    this.adherents,
    this.entraineurs,
    this.convocations,
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'],
      nom: json['nom'],
      genre: json['genre'],
      groupeAge: json['groupeAge'],
      couleur: json['couleur'],
      codeEquipe: json['codeEquipe'],
      logo: json['logo'],
      discipline: json['discipline'] != null
          ? [Discipline.fromJson(json['discipline'])]
          : null,
      adherents: json['adherents'],
      entraineurs: json['entraineurs'],
      convocations: json['convocations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'genre': genre,
      'groupeAge': groupeAge,
      'couleur': couleur,
      'codeEquipe': codeEquipe,
      'logo': logo,
      'discipline': discipline,
      'adherents': adherents,
      'entraineurs': entraineurs,
      'convocations': convocations,
    };
  }
}
