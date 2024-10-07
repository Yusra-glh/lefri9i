import 'package:dio/dio.dart';
import 'package:gark_academy/models/event_model.dart';
import 'package:gark_academy/models/test_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';

class EventService {
  final Dio _dio = Dio();
  final MemberService userService = MemberService();
  List<User> _members = [];
  List<User> get members => _members;

  Future<List<Event>> getAdherantEvents() async {
    const url = '$baseUrl/evenement/getEvenementstByAdherent';
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
        List<Event> events = (response.data as List)
            .map((json) => Event.fromJson(json))
            .toList();
        return events;
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<List<Event>> getCoachEvents() async {
    const url = '$baseUrl/evenement/getEvenementstByCoach';
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
        List<Event> events = (response.data as List)
            .map((json) => Event.fromJson(json))
            .toList();
        return events;
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<List<User>> fetchEventMembers(int eventId) async {
    final url = '$baseUrl/evenement/getMembersByEvenement/$eventId';

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

  Future<void> updateEventAttendance(int attendanceId, bool isPresent) async {
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

  Future<Event> getEventDetails(int eventId) async {
    final url = '$baseUrl/evenement/detail/$eventId';

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
        return Event.fromJson(response.data);
      } else {
        throw Exception('Failed to load test data');
      }
    } catch (e) {
      print('Failed to load test data: $e');
      throw e;
    }
  }

  //Test evaluation
  Future<Test> fetchTestData(int attendanceId) async {
    final url = '$baseUrl/evenement/getTests/$attendanceId';

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
        return Test.fromJson(response.data);
      } else {
        throw Exception('Failed to load test data');
      }
    } catch (e) {
      print('Failed to load test data: $e');
      throw e;
    }
  }

  Future<void> updateTestData(int testId, Test testData) async {
    final url = '$baseUrl/evenement/updateTest/$testId';

    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      Response response = await Dio().post(
        url,
        data: testData.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Test data updated successfully');
      } else {
        throw Exception(
            'Failed to update test data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (e) {
      print('Failed to update test data: $e');
      throw e;
    }
  }
}
