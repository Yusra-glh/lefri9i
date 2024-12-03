import 'package:flutter/material.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/coach_service.dart';

class CoachProvider with ChangeNotifier {
  User? _user;
  final _coachService = CoachService();

  User? get user => _user;

  Future<void> fetchCoach() async {
    final userId = await _coachService.getConnectedUserId();
    _user = await _coachService.getCoachInformations(userId);
    notifyListeners();
  }

  Future<void> updateCoachProfile(Map<String, dynamic> updatedFields) async {
    if (_user != null) {
      await _coachService.updateCoachProfile(_user!, updatedFields);
      await fetchCoach();
    }
  }

  Future<bool> confirmPassword(String email, String password) async {
    final response = await _coachService.confirmPassword(email, password);
    return response.statusCode == 200;
  }

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _coachService.fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup(
      {required String groupName, required List<int> members}) async {
    try {
      await _coachService.createGroup(groupName: groupName, members: members);
      notifyListeners();
    } catch (e) {
      // Handle errors, e.g., show a SnackBar
      throw Exception('Failed to create group: $e');
    }
  }
}
