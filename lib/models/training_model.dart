import 'package:gark_academy/models/attendance_model.dart';

class Training {
  final int id;
  final String date;
  final String? heure;
  final String? terrain;
  final List<String?>? adherents;
  final List<Attendance?>? attendances;

  Training({
    required this.id,
    required this.date,
    this.heure,
    this.terrain,
    this.adherents,
    List<Attendance?>? attendances,
  }) : attendances = attendances ?? [];

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'],
      date: json['date'],
      heure: json['heure'],
      terrain: json['terrain'],
      adherents: json['adherents'] != null
          ? List<String>.from(json['adherents'])
          : null,
      attendances: (json['attendances'] as List<dynamic>?)
              ?.map((e) => Attendance.fromJson(e))
              .toList() ??
          [],
    );
  }
}
