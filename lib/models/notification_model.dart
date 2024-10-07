class NotificationModel {
  final int id;
  final String message;
  final String link;
  final DateTime creationDate;
  bool viewed;

  NotificationModel({
    required this.id,
    required this.message,
    required this.link,
    required this.creationDate,
    required this.viewed,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      link: json['link'] ?? '',
      creationDate: DateTime.parse(json['creationDate']),
      viewed: json['viewed'],
    );
  }

  void markAsViewed() {
    viewed = true;
  }
}
