import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> attemptLogin(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    await Future.delayed(const Duration(seconds: 1));
    await _authService.saveUserData(email, "CineScope User"); 
    
    _setLoading(false);
    return true;
  }

  Future<bool> attemptRegister(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    await Future.delayed(const Duration(seconds: 1));
    await _authService.saveUserData(email, name); 
    
    _setLoading(false);
    return true;
  }
}