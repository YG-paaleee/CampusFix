import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/student_user.dart';
import '../utils/student_identity.dart';

class StudentAuthService extends ChangeNotifier {
  StudentAuthService({
    String? authApiKey,
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  }) : _authApiKey = authApiKey,
       _firestore = firestore,
       _httpClient = httpClient ?? http.Client();

  final String? _authApiKey;
  final FirebaseFirestore? _firestore;
  final http.Client _httpClient;

  StudentUser? _currentStudent;
  String? _errorMessage;
  bool _isLoading = false;

  StudentUser? get currentStudent => _currentStudent;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentStudent != null;

  Future<void> restoreSession() async {
    // REST auth is intentionally session-light for this MVP.
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    final email = normalizeStudentLoginIdentifier(identifier);

    if (email == null) {
      _errorMessage =
          'Use your PSU student ID or school email, for example 2023-8-0099.';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Enter your password.';
      notifyListeners();
      return false;
    }

    final apiKey = _authApiKey;

    if (apiKey == null) {
      _currentStudent = StudentUser(
        uid: 'demo-student',
        studentId: studentIdFromEmail(email),
        displayName: email,
        email: email,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _setLoading(true);

    try {
      final authData = await _postAuthRequest(
        apiKey: apiKey,
        endpoint: 'accounts:signInWithPassword',
        body: {'email': email, 'password': password, 'returnSecureToken': true},
      );

      await _loadStudentProfile(
        uid: authData.uid,
        email: authData.email,
        fallbackDisplayName: authData.email,
      );
      _errorMessage = null;
      return true;
    } on _AuthRequestException catch (error) {
      _errorMessage = _authErrorMessage(error.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerStudent({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    final cleanFullName = fullName.trim();
    final cleanStudentId = studentId.trim();
    final cleanEmail = emailFromStudentId(cleanStudentId);

    if (cleanFullName.isEmpty) {
      _errorMessage = 'Enter your full name.';
      notifyListeners();
      return false;
    }

    if (!isValidStudentId(cleanStudentId)) {
      _errorMessage = 'Use the PSU student ID format, for example 2023-8-0099.';
      notifyListeners();
      return false;
    }

    final apiKey = _authApiKey;

    if (apiKey == null) {
      _currentStudent = StudentUser(
        uid: 'demo-student',
        studentId: cleanStudentId,
        displayName: cleanFullName,
        email: cleanEmail,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _setLoading(true);

    try {
      final authData = await _postAuthRequest(
        apiKey: apiKey,
        endpoint: 'accounts:signUp',
        body: {
          'email': cleanEmail,
          'password': password,
          'returnSecureToken': true,
        },
      );

      final student = StudentUser(
        uid: authData.uid,
        studentId: cleanStudentId,
        displayName: cleanFullName,
        email: cleanEmail,
      );

      await _firestore
          ?.collection('students')
          .doc(authData.uid)
          .set(student.toJson());

      _currentStudent = student;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on _AuthRequestException catch (error) {
      _errorMessage = _authErrorMessage(error.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentStudent = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<_RestAuthUser> _postAuthRequest({
    required String apiKey,
    required String endpoint,
    required Map<String, Object> body,
  }) async {
    final response = await _httpClient.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/$endpoint?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'] as Map<String, dynamic>?;
      throw _AuthRequestException(error?['message']?.toString() ?? 'UNKNOWN');
    }

    return _RestAuthUser(
      uid: data['localId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
    );
  }

  Future<void> _loadStudentProfile({
    required String uid,
    required String email,
    required String fallbackDisplayName,
  }) async {
    final profile = await _firestore?.collection('students').doc(uid).get();
    final data = profile?.data();

    if (data != null) {
      _currentStudent = StudentUser.fromJson({...data, 'uid': uid});
    } else {
      _currentStudent = StudentUser(
        uid: uid,
        studentId: studentIdFromEmail(email),
        displayName: fallbackDisplayName,
        email: email,
      );
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _authErrorMessage(String code) {
    final normalizedCode = code.split(' : ').first;

    return switch (normalizedCode) {
      'EMAIL_EXISTS' => 'That email already has an account. Go back to login.',
      'INVALID_EMAIL' => 'Enter a valid PSU school email.',
      'WEAK_PASSWORD' => 'Use a stronger password with at least 6 characters.',
      'OPERATION_NOT_ALLOWED' =>
        'Email/Password sign-in is not enabled in Firebase Authentication.',
      'INVALID_LOGIN_CREDENTIALS' ||
      'EMAIL_NOT_FOUND' ||
      'INVALID_PASSWORD' => 'Email or password is incorrect.',
      'TOO_MANY_ATTEMPTS_TRY_LATER' =>
        'Too many attempts. Wait a while, then try again.',
      _ => 'Firebase Auth failed: $code.',
    };
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}

class _RestAuthUser {
  const _RestAuthUser({required this.uid, required this.email});

  final String uid;
  final String email;
}

class _AuthRequestException implements Exception {
  const _AuthRequestException(this.code);

  final String code;
}
