import 'package:gark_academy/models/user_model.dart';

class Attendance {
  final int id;
  final User adherent;
  final bool present;

  Attendance({
    required this.id,
    required this.adherent,
    required this.present,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      adherent: User.fromJson(json['adherent']),
      present: json['present'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Attendance{id: $id, adherent: $adherent, present: $present}';
  }
}
