import 'package:gark_academy/models/academy_model.dart';

class Post {
  final int id;
  final String title;
  final String subtitle;
  final String body;
  final String author;
  final String authorImageUrl;
  final String category;
  final String imageUrl;
  final bool publicAudience;
  final String createdAt;
  final Academy? academy;

  Post({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.author,
    required this.authorImageUrl,
    required this.category,
    required this.imageUrl,
    required this.publicAudience,
    required this.createdAt,
    this.academy,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      body: json['body'],
      author: json['author'],
      authorImageUrl: json['authorImageUrl'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      publicAudience: json['publicAudience'],
      createdAt: json['createdAt'],
      academy:
          json['academie'] != null ? Academy.fromJson(json['academie']) : null,
    );
  }
}
