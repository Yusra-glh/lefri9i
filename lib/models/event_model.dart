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
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, type: $type, nomEvent: $nomEvent, lieu: $lieu, date: $date, heure: $heure, description: $description, repetition: $repetition, typeRepetition: $typeRepetition, nbRepetition: $nbRepetition, attendances: ${attendances.map((a) => a.toString()).toList()}}';
  }
}
