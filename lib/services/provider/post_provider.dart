import 'package:flutter/material.dart';
import 'package:gark_academy/models/post_model.dart';
import 'package:gark_academy/services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAdherantPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _postService.getAdherantPosts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchManagerPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _postService.getCoachPosts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
