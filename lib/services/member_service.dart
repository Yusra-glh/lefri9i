import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class MemberService {
  final Dio _dio = Dio();

  //get connected user Id
  Future<int> getConnectedUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    return userId!;
  }

  Future<User> getAdherantInformations(int userId) async {
    final url = '$baseUrl/member/getMember/$userId';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      Response response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final user = User.fromJson(responseData);
        log(
          "current user--------------------$responseData",
        );
        // Save user information to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user.id);
        await prefs.setString('userFirstname', user.firstname);
        await prefs.setString('userLastname', user.lastname);
        await prefs.setString('userEmail', user.email);
        await prefs.setString('userRole', user.role);
        await prefs.setString('userTelephone', user.telephone ?? '');
        await prefs.setString('userAdresse', user.adresse ?? '');
        await prefs.setString('userDateNaissance', user.dateNaissance ?? '');
        await prefs.setString('userNationalite', user.nationalite ?? '');
        await prefs.setString(
            'userPhoto',
            user.photo ??
                'https://ui-avatars.com/api/?name=${user.firstname}+${user.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150');
        await prefs.setString('userNiveauScolaire', user.niveauScolaire ?? '');
        await prefs.setString(
            'userInformationParent', jsonEncode(user.informationParent));
        await prefs.setString(
            'userConditionMedicale', user.conditionMedicale ?? '');
        await prefs.setString('userStatutAdherent', user.statutAdherent ?? '');
        await prefs.setString('userRoleName', user.roleName ?? '');
        await prefs.setString('userAcademieName', user.academieName ?? '');

        if (user.equipeIds != null) {
          await prefs.setString('userEquipeIds', jsonEncode(user.equipeIds));
        }
        if (user.allergies != null) {
          await prefs.setString('userAllergies', jsonEncode(user.allergies));
        }
        if (user.medicamentActuel != null) {
          await prefs.setString(
              'userMedicamentActuel', jsonEncode(user.medicamentActuel));
        }
        if (user.medicamentPasses != null) {
          await prefs.setString(
              'userMedicamentPasses', jsonEncode(user.medicamentPasses));
        }
        if (user.equipes != null) {
          await prefs.setString('userEquipes',
              jsonEncode(user.equipes!.map((e) => e.toJson()).toList()));
        }

        return user;
      } else {
        throw Exception('Failed to load user information');
      }
    } catch (e) {
      print('Failed to get User INFOS: $e');
      throw Exception('Failed to load user information: $e');
    }
  }

  Future<void> updateUserMedicalInformation(
      int userId, Map<String, dynamic> medicalInfo) async {
    final url = '$baseUrl/member/updateMemberMedicalInformation/$userId';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      Response response = await _dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: jsonEncode(medicalInfo),
      );

      if (response.statusCode == 200) {
        log('Medical information updated successfully');
      } else {
        throw Exception('Failed to update medical information');
      }
    } catch (e) {
      log('Failed to update medical information: $e');
      throw Exception('Failed to update medical information: $e');
    }
  }

  Future<Response> confirmPassword(String email, String password) async {
    const url = '$baseUrl/auth/authenticate';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        log('Network error: $e');
        throw Exception('Network error occurred.');
      }
    }
  }

  Future<void> updateMemberProfile(
      User user, Map<String, dynamic> updatedFields) async {
    try {
      // Fetch the access token from storage
      String? accessToken = await getAccessTokenFromStorage();
      log('access token : $accessToken');
      if (accessToken == null) {
        throw Exception('Access token not found');
      }
      log("update profile ----------- ${jsonEncode(updatedFields)}");
      log("update profile url ----------- $baseUrl/member/updateMemberProfile");
      // Make the API call to update the user profile
      final response = await http.post(
        Uri.parse('$baseUrl/member/updateMemberProfile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updatedFields),
      );
      log('User profile updated ***** ${response.statusCode}');

      if (response.statusCode == 202) {
        // Update SharedPreferences only if the API call is successful
        log('User profile updated successfully');

        // Retrieve and save the updated user information
        await getAdherantInformations(user.id);
      } else {
        log('Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      log('Error updating member profile here: $e');
    }
  }
}
