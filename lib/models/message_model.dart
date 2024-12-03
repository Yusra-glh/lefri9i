import 'package:gark_academy/models/user_model.dart';

class MessageModel {
  final int senderId;
  final List<int>? receiversId;
  final String message;
  final String? senderName;
  final String? groupeName;
  final String timestamp;

  MessageModel({
    required this.senderId,
    this.receiversId,
    required this.message,
    this.senderName,
    this.groupeName,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      receiversId: json['receiversId'] != null
          ? List<int>.from(json['receiversId'])
          : [],
      message: json['message'],
      senderName: json['senderName'],
      groupeName: json['groupeName'],
      timestamp: json['timestamp'],
    );
  }
}

class UserWithLastMessage {
  final User user;
  final String lastMessageContent;
  final String lastMessageTimeAgo;

  UserWithLastMessage({
    required this.user,
    required this.lastMessageContent,
    required this.lastMessageTimeAgo,
  });
}

class UserOrGroupWithMessages {
  final int? userId;
  final String? username;
  final int? groupId;
  final String? groupName;

  UserOrGroupWithMessages({
    this.userId,
    this.username,
    this.groupId,
    this.groupName,
  });

  factory UserOrGroupWithMessages.fromJson(Map<String, dynamic> json) {
    return UserOrGroupWithMessages(
      userId: json['userId'],
      username: json['username'] as String?,
      groupId: json['groupId'],
      groupName: json['groupName'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserOrGroupWithMessages(userId: $userId, username: $username, groupId: $groupId, groupName: $groupName)';
  }
}
