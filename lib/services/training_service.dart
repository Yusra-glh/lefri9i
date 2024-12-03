import 'package:dio/dio.dart';
import 'package:gark_academy/models/training_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';

class TrainingService {
  final Dio _dio = Dio();
  final MemberService userService = MemberService();

  Future<List<Training>> getAdherantTraining() async {
    const url = '$baseUrl/entrainement/getEntrainementByAdherent';
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
        List<Training> trainingList = (response.data as List)
            .map((json) => Training.fromJson(json))
            .toList();
        return trainingList;
      } else {
        throw Exception('Failed to load user training');
      }
    } catch (e) {
      throw Exception('Failed to load user events: $e');
    }
  }

  Future<List<Training>> getCoachTraining() async {
    const url = '$baseUrl/entrainement/getEntrainementByCoach';
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
        List<Training> trainingList = (response.data as List)
            .map((json) => Training.fromJson(json))
            .toList();
        return trainingList;
      } else {
        throw Exception('Failed to load coach training');
      }
    } catch (e) {
      throw Exception('Failed to load coach training: $e');
    }
  }

  Future<List<User>> fetchTrainingMembers(int trainingId) async {
    final url = '$baseUrl/entrainement/getAdherentsByConvocation/$trainingId';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await getAccessTokenFromStorage()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      print('Failed to load members: $e');
      throw e;
    }
  }

  Future<void> updateTrainingAttendance(
      int attendanceId, bool isPresent) async {
    final url = '$baseUrl/evenement/updateAttendance/$attendanceId';

    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      Response response = await _dio.post(
        url,
        data: isPresent,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Attendance updated successfully');
      } else {
        throw Exception(
            'Failed to update attendance: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (e) {
      print('Failed to update attendance: $e');
      throw e;
    }
  }
}
