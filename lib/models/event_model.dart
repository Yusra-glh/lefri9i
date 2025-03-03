import 'package:gark_academy/models/attendance_model.dart';

class Event {
  final int id;
  final String type;
  final String nomEvent;
  final String lieu;
  final String date;
  final String? heure;
  final String? statut;
  final String? description;
  final bool? repetition;
  final String? typeRepetition;
  final int? nbRepetition;
  final List<Attendance?> attendances;
  final ConvocationEquipe? convocationEquipe;
  final bool? intrested;

  Event({
    required this.id,
    required this.type,
    required this.nomEvent,
    required this.lieu,
    required this.date,
    this.statut,
    this.heure,
    this.description,
    this.repetition,
    this.typeRepetition,
    this.nbRepetition,
    List<Attendance?>? attendances,
     this.convocationEquipe,
    this.intrested,
  }) : attendances = attendances ?? [];

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      type: json['type'],
      nomEvent: json['nomEvent'],
      lieu: json['lieu'],
      date: json['date'],
      heure: json['heure'],
      statut: json['statut'],
      description: json['description'] ?? "",
      repetition: json['repetition'],
      typeRepetition: json['typeRepetition'],
      nbRepetition: json['nbRepetition'],
      attendances: (json['attendances'] as List<dynamic>?)
              ?.map((e) => Attendance.fromJson(e))
              .toList() ??
          [],
            convocationEquipe: json['convocationEquipe'] != null
          ? ConvocationEquipe.fromJson(json['convocationEquipe'])
          : json['convocationEquipesMatchAmical'] != null
              ? (json['convocationEquipesMatchAmical'] as List).isNotEmpty
                  ? ConvocationEquipe.fromJson((json['convocationEquipesMatchAmical'] as List)[0]['equipe'])
                  : null
              : null,
      intrested: json['interested'],
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, type: $type, nomEvent: $nomEvent, lieu: $lieu, date: $date, heure: $heure, description: $description, repetition: $repetition, typeRepetition: $typeRepetition, nbRepetition: $nbRepetition, attendances: ${attendances.map((a) => a.toString()).toList()}}';
  }
}

class ConvocationEquipe {
  final int? id;
  final String? nom;
  // final String? genre;
  // final int? groupeAge;
  // final String? couleur;
  // final int? codeEquipe;
  // final String? logo;
  // final Discipline? discipline;

  ConvocationEquipe({
    this.id,
    this.nom,
    // this.genre,
    // this.groupeAge,
    // this.couleur,
    // this.codeEquipe,
    // this.logo,
    // this.discipline,
  });

  factory ConvocationEquipe.fromJson(Map<String, dynamic> json) {
    return ConvocationEquipe(
      id: json['id'],
      nom: json['nom'],
      // genre: json['genre'],
      // groupeAge: json['groupeAge'],
      // couleur: json['couleur'],
      // codeEquipe: json['codeEquipe'],
      // logo: json['logo'],
      // discipline: Discipline.fromJson(json['discipline']),
    );
  }

  @override
  String toString() {
    return 'ConvocationEquipe{id: $id, nom: $nom }';
    // , genre: $genre, groupeAge: $groupeAge, couleur: $couleur, codeEquipe: $codeEquipe, logo: $logo, discipline: $discipline
  }
}