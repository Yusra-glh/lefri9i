import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/payment_service.dart';

class MemberProvider with ChangeNotifier {
  User? _user;
  String? _paymentStatus;
  final MemberService _memberService = MemberService();
  final PaymentService _paymentService = PaymentService();
  User? get user => _user;
  String? get paymentStatus => _paymentStatus;

  Future<void> fetchUser() async {
    final userId = await _memberService.getConnectedUserId();
    _user = await _memberService.getAdherantInformations(userId);
    log("user informationsSportives----------------------- ${_user?.informationsSportives?.toString()}");
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> updatedFields) async {
    if (_user != null) {
      await _memberService.updateMemberProfile(_user!, updatedFields);
      await fetchUser();
    }
  }

  Future<bool> confirmPassword(String email, String password) async {
    final response = await _memberService.confirmPassword(email, password);
    return response.statusCode == 200;
  }

  checkPaymentStatus() async {
    _paymentStatus = await _paymentService.checkPaymentStatus();
    notifyListeners();
  }
}
