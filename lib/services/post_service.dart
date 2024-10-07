import 'package:dio/dio.dart';
import 'package:gark_academy/models/post_model.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';

class PostService {
  final Dio _dio = Dio();
  final MemberService userService = MemberService();

  Future<List<Post>> getPublicPosts() async {
    try {
      Response response = await _dio.get('$baseUrl/posts/getpublicPosts');
      if (response.statusCode == 200) {
        List<Post> posts =
            (response.data as List).map((json) => Post.fromJson(json)).toList();
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<Post>> getAdherantPosts() async {
    const url = '$baseUrl/posts/getadherentPosts';
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
        List<Post> posts =
            (response.data as List).map((json) => Post.fromJson(json)).toList();
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<Post>> getCoachPosts() async {
    const url = '$baseUrl/posts/getadherentPosts';
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
        List<Post> posts =
            (response.data as List).map((json) => Post.fromJson(json)).toList();
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }
}
