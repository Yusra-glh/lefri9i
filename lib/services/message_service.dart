// message_service.dart
import 'package:dio/dio.dart';
import 'package:gark_academy/models/message_model.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';

class MessageService {
  final Dio _dio = Dio();
  final MemberService userService = MemberService();

  Future<List<UserOrGroupWithMessages>> fetchUsersWithMessages() async {
    const url = '$baseUrl/chat/usersWithMessages';

    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data
            .map((json) => UserOrGroupWithMessages.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load users or groups');
      }
    } catch (e) {
      throw Exception('Failed to load users or groups: $e');
    }
  }

  Future<List<MessageModel>> getChatHistory(
      {int? userId2, int? equipeId}) async {
    String url;
    if (userId2 != null) {
      url = '$baseUrl/chat/history?userId2=$userId2';
    } else if (equipeId != null) {
      url = '$baseUrl/chat/history?equipeId=$equipeId';
    } else {
      throw Exception('Either userId2 or equipeId must be provided');
    }

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
        List<MessageModel> messages =
            data.map((json) => MessageModel.fromJson(json)).toList();
        return messages;
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      throw Exception('Failed to load chat history: $e');
    }
  }

  Future<MessageModelWithTimestamp?> getLastMessageFromDiscussion(
      {int? userId2, int? equipeId}) async {
    try {
      List<MessageModel> messages =
          await getChatHistory(userId2: userId2, equipeId: equipeId);

      if (messages.isEmpty) {
        return null;
      }

      // Sort messages by timestamp in descending order
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return MessageModelWithTimestamp(
        message: messages.first.message,
        timestampString: messages.first.timestamp,
      );
    } catch (e) {
      throw Exception('Failed to get last message: $e');
    }
  }

  Future<void> sendMessage({
    required List<int?> receiversId,
    required String message,
    int? idEquipe,
  }) async {
    const url = '$baseUrl/chat/send';

    try {
      String? accessToken = await getAccessTokenFromStorage();
      if (accessToken == null) {
        throw Exception('Access token not available');
      }

      Map<String, dynamic> data = {
        'receiversId': receiversId,
        'message': message,
        'idEquipe': idEquipe,
      };

      Response response = await _dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}

class MessageModelWithTimestamp {
  final String message;
  final String timestampString;

  MessageModelWithTimestamp(
      {required this.message, required this.timestampString});
}

class UserWithMessages {
  final int userId;
  final String username;
  final String? groupId;
  final String? groupName;
  final DateTime timestamp;

  UserWithMessages({
    required this.userId,
    required this.username,
    this.groupId,
    this.groupName,
    required this.timestamp,
  });

  factory UserWithMessages.fromJson(Map<String, dynamic> json) {
    return UserWithMessages(
      userId: json['userId'],
      username: json['username'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return 'UserWithMessages{userId: $userId, username: $username, groupId: $groupId, groupName: $groupName, timestamp: $timestamp}';
  }
}
