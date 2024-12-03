import 'package:flutter/material.dart';
import 'package:gark_academy/models/message_model.dart';
import 'package:gark_academy/services/message_service.dart';

class MessageProvider with ChangeNotifier {
  final MessageService _messageService = MessageService();
  List<UserOrGroupWithMessages>? _usersWithMessages;
  bool _isLoading = false;
  String? _error;

  List<UserOrGroupWithMessages>? get usersWithMessages => _usersWithMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MessageProvider() {
    fetchUsersWithMessages();
  }

  Future<void>? fetchUsersWithMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usersWithMessages = await _messageService.fetchUsersWithMessages();
    } catch (e) {
      _error = 'Failed to load users or groups with messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
