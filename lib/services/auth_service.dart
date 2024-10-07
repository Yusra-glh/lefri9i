import 'dart:convert';
import 'dart:developer';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:gark_academy/services/coach_service.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Dio dio;
  CookieJar cookieJar;
  final MemberService _memberService = MemberService();
  final CoachService _coachService = CoachService();

  AuthService()
      : dio = Dio(),
        cookieJar = CookieJar() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

// Register adherant function
  Future<Response> registerAdherant(
      {required String firstname,
      required String lastname,
      required String email,
      required String password,
      required String telephone,
      required String teamCode,
      required String fcmToken}) async {
    const url = '$baseUrl/auth/register/member';

    try {
      final body = jsonEncode(<String, String>{
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'telephone': telephone,
        'code': teamCode,
        'fcmToken': fcmToken
      });
      log("register body -------------- $body");
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: body,
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        final accessToken = responseBody['access_token'];
        final refreshToken = responseBody['refresh_token'];
        final academyName = responseBody['academy']['nom'];
        final academyLogo = responseBody['academy']['logo'];
        final userId = responseBody['user']['id'];
        final userName = (responseBody['user']['firstname'] ?? '') +
            ' ' +
            (responseBody['user']['lastname'] ?? '');

        // Save access token and refresh token to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setString('academyName', academyName);
        await prefs.setString('academyLogo', academyLogo);
        //
        final userInfo = {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'academyName': academyName,
          'academyLogo': academyLogo,
          'userName': userName,
          'userId': userId,
          'email': email,
          'password': password
        };

        List<String> usersList = prefs.getStringList('usersList') ?? [];

        // Check if the user with the same userId already exists
        bool userExists = usersList.any((user) {
          final decodedUser = jsonDecode(user) as Map<String, dynamic>;
          return decodedUser['userId'] == userId;
        });

        if (!userExists) {
          usersList.add(jsonEncode(userInfo));
          await prefs.setStringList('usersList', usersList);
        } else {
          print('User with userId $userId already exists.');
        }

        // Retrieve user ID from response or another method
        final role = responseBody['user']['role'];

        if (role == "ADHERENT") {
          // Fetch and save remaining user details
          await _memberService.getAdherantInformations(userId);
        } else if (role == "ENTRAINEUR") {
          // Fetch and save remaining user details
          await _coachService.getCoachInformations(userId);
        }

        print("academyName = $academyName");
        print("academyLogo = $academyLogo");

        return response;
      } else {
        throw Exception('Failed to register');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        // ignore: avoid_print
        print('Network error: $e');
        throw Exception('Network error occurred.');
      }
    }
  }

  // Login function
  Future<Response> loginUser(
      String email, String password, String? fcmToken) async {
    const url = '$baseUrl/auth/authenticate';
    log("------------------fcm token to send $fcmToken");
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: jsonEncode(
            {'email': email, 'password': password, 'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        final accessToken = responseBody['access_token'];
        final refreshToken = responseBody['refresh_token'];
        final academyName = responseBody['academy']['nom'];
        final academyLogo = responseBody['academy']['logo'];

        // Save access token and refresh token to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setString('academyName', academyName);
        await prefs.setString('academyLogo', academyLogo);
        // Retrieve user ID from response or another method
        final userId = responseBody['user']['id'];
        final role = responseBody['user']['role'];
        final userName = (responseBody['user']['firstname'] ?? '') +
            ' ' +
            (responseBody['user']['lastname'] ?? '');
        final userInfo = {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'academyName': academyName,
          'academyLogo': academyLogo,
          'userName': userName,
          'userId': userId,
          'email': email,
          'password': password
        };

        List<String> usersList = prefs.getStringList('usersList') ?? [];

// Check if the user with the same userId already exists
        bool userExists = usersList.any((user) {
          final decodedUser = jsonDecode(user) as Map<String, dynamic>;
          return decodedUser['userId'] == userId;
        });

        if (!userExists) {
          usersList.add(jsonEncode(userInfo));
          await prefs.setStringList('usersList', usersList);
        } else {
          print('User with userId $userId already exists.');
        }

        if (role == "ADHERENT") {
          // Fetch and save remaining user details
          await _memberService.getAdherantInformations(userId);
        } else if (role == "ENTRAINEUR") {
          // Fetch and save remaining user details
          await _coachService.getCoachInformations(userId);
        }

        print("academyName = $academyName");
        print("academyLogo = $academyLogo");

        return response;
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        // ignore: avoid_print
        print('Network error: $e');
        throw Exception('Network error occurred.');
      }
    }
  }

  Future<bool> checkAccessToken(String accessToken) async {
    const url = '$baseUrl/auth/checkAccessToken';
    final response = await dio.get(
      url,
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print("Response from CheckAccessToken = ${response.data}");
      return response.data == true;
    }
    return false;
  }

  Future<String?> getAccessTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    print("Access Token from storage YO YO= $accessToken");
    return accessToken;
  }

  Future<void> logout() async {
    const url = '$baseUrl/auth/logout';
    await dio.post(url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> deleteProfile() async {
    const url = '$baseUrl/user/deleteProfile';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        // Profile deleted successfully
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        return;
      } else {
        throw Exception('Failed to delete profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to delete profile: ${e.response!.data}');
      } else {
        throw Exception('Network error occurred.');
      }
    }
  }
  Future<void> updateFcmToken() async {
    const url = '$baseUrl/user/refreshFCM';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        // Profile deleted successfully
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        return;
      } else {
        throw Exception('Failed to delete profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to delete profile: ${e.response!.data}');
      } else {
        throw Exception('Network error occurred.');
      }
    }
  }
  
}
