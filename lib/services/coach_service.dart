import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachService {
  final Dio _dio = Dio();

  //get connected user Id
  Future<int> getConnectedUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    return userId!;
  }

  Future<List<User>> fetchUsers() async {
    const url = '$baseUrl/academie/get-users';
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
        List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<User> getCoachInformations(int userId) async {
    final url = '$baseUrl/coach/$userId';
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
        if (user.photo == null || user.photo == '') {
          await prefs.setString('userPhoto',
              'https://ui-avatars.com/api/?name=${user.firstname}+${user.lastname}&uppercase=true&color=ffffff&background=000000&rounded=true&size=150');
        } else {
          await prefs.setString('userPhoto', user.photo!);
        }
        await prefs.setString('userAcademieName', user.academieName ?? '');

        print("this is the saved user photo:: ${prefs.getString('userPhoto')}");
        return user;
      } else {
        throw Exception('Failed to load user information');
      }
    } catch (e) {
      print('Failed to get User INFOS: $e');
      throw Exception('Failed to load user information: $e');
    }
  }

  Future<void> updateCoachProfile(
      User user, Map<String, dynamic> updatedFields) async {
    try {
      // Fetch the access token from storage
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not found');
      }

      // Make the API call to update the user profile
      final response = await _dio.post(
        '$baseUrl/user/updateProfile',
        data: updatedFields,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 202) {
        // Update SharedPreferences only if the API call is successful
        print('User profile updated successfully');

        // Retrieve and save the updated user information
        await getCoachInformations(user.id);
      } else {
        print('Failed to update user profile: ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Error updating member profile: ${e.response?.data}');
      } else {
        print('Error updating member profile: $e');
      }
    } catch (e) {
      print('Error updating member profile: $e');
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
        print('Network error: $e');
        throw Exception('Network error occurred.');
      }
    }
  }

  Future<void> createGroup(
      {required String groupName, required List<int> members}) async {
    const url = '$baseUrl/chat/createGroupe';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      final response = await _dio.post(
        url,
        data: {
          'name': groupName,
          'members': members,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        print("Group created successfully");
      } else {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }
}
