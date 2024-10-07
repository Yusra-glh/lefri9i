import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:gark_academy/models/payment_model.dart';
import 'package:gark_academy/utils/Constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  final Dio _dio = Dio();

  Future<List<Payment>> getPaymentHistory() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('User ID not available');
      }

      // Construct the URL
      final url = '$baseUrl/paiement/getPaiementHistory/$userId';

      // Retrieve the access token from SharedPreferences
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      // Make the HTTP GET request
      final Response response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final List<Payment> payments = (response.data as List)
            .map((json) => Payment.fromJson(json))
            .toList();
        return payments;
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  Future<String?> checkPaymentStatus() async {
    List<Payment> paymentHistory = await getPaymentHistory();
    if (paymentHistory.isEmpty) return null;

    // Sort payment history by id in descending order to get the latest payment
    paymentHistory.sort((a, b) => b.id.compareTo(a.id));
    Payment latestPayment = paymentHistory.first;

    DateTime now = DateTime.now();
    DateTime dateFin = DateFormat('yyyy-MM-dd').parse(latestPayment.dateFin);
    log("lastPAyment ---------------- $dateFin");
    int retardPaymentDays = now.difference(dateFin).inDays;
    log("retardPaymentDays ---------------- $retardPaymentDays");
    if (retardPaymentDays >= 0) {
      return 'red';
    } else if (now.isAfter(dateFin.subtract(const Duration(days: 3)))) {
      return 'superRed';
    } else if (now.isAfter(dateFin.subtract(const Duration(days: 5)))) {
      return 'orange';
    }
    return "green";
  }
}
