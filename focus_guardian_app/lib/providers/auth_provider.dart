import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  UserProfile _user = UserProfile();

  bool get isLoggedIn => _isLoggedIn;
  UserProfile get user => _user;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (_isLoggedIn) {
      _user.username = prefs.getString(AppConstants.keyUsername) ?? 'Student';
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    // For offline/local mode, accept any non-empty credentials
    if (username.isNotEmpty && password.length >= 4) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUsername, username);
      _user.username = username;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String username, String email, String password) async {
    if (username.isNotEmpty && email.contains('@') && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUsername, username);
      _user.username = username;
      _user.email = email;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    _isLoggedIn = false;
    _user = UserProfile();
    notifyListeners();
  }
}
