import 'package:flutter/material.dart';
import 'package:gark_academy/models/training_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/training_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';

class TrainingProvider with ChangeNotifier {
  List<Training> _trainings = [];
  List<Training> get trainings => _trainings;
  DateTime now = DateTime.now();
  List<User> _members = [];
  List<User> get members => _members;

  final TrainingService _trainingService = TrainingService();

  Future<void> fetchAdherantTrainings() async {
    try {
      _trainings = await _trainingService.getAdherantTraining();
      // _trainings = _trainings
      //     .where((training) =>
      //         DateTime.parse(training.date).isAfter(now) ||
      //         isSameDate(DateTime.parse(training.date), now))
      //     .toList();
      // ..sort(
      //     (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      notifyListeners();
    } catch (e) {
      print('Failed to load trainings: $e');
    }
  }

  Future<void> fetchCoachTrainings() async {
    try {
      _trainings = await _trainingService.getCoachTraining();
      // _trainings = _trainings
      //     .where((training) =>
      //         DateTime.parse(training.date).isAfter(now) ||
      //         isSameDate(DateTime.parse(training.date), now))
      //     .toList();
      // ..sort(
      //     (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      notifyListeners();
    } catch (e) {
      print('Failed to load trainings: $e');
    }
  }

  Future<void> fetchTrainingMembers(int trainingId) async {
    try {
      _members = await _trainingService.fetchTrainingMembers(trainingId);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch event members: $e');
    }
  }

  Future<void> updateTrainingAttendance(
      int attendanceId, bool isPresent) async {
    try {
      await _trainingService.updateTrainingAttendance(attendanceId, isPresent);

      notifyListeners();
    } catch (e) {
      print('Failed to update attendance: $e');
    }
  }
}
