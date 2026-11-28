import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/model/auth_model.dart';

class SessionService extends GetxService {
  SessionService._();

  static SessionService get to => Get.find<SessionService>();

  static const String _keyAuthToken = 'auth_token';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyIsDutyActive = 'is_duty_active';
  static const String _keyIsOnBreak = 'is_on_break';
  static const String _keyThemeMode = 'theme_mode';

  late SharedPreferences _prefs;

  // Reactive session data
  final Rx<AuthModel?> currentUser = Rx<AuthModel?>(null);
  final RxString authToken = ''.obs;

  final RxBool isDutyActive = false.obs;
  final RxBool isOnBreak = false.obs;

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  // Session status
  bool get isLoggedIn => authToken.value.isNotEmpty;

  SharedPreferences get preferences => _prefs;

  // --------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------

  static Future<SessionService> init() async {
    final service = SessionService._();

    await service._initialize();

    return service;
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();

    _restoreSession();
  }

  void _restoreSession() {
    authToken.value = _prefs.getString(_keyAuthToken) ?? '';

    isDutyActive.value = _prefs.getBool(_keyIsDutyActive) ?? false;
    isOnBreak.value = _prefs.getBool(_keyIsOnBreak) ?? false;

    final savedMode = _prefs.getString(_keyThemeMode);
    if (savedMode == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (savedMode == 'system') {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = ThemeMode.light;
    }

    final userJson = _prefs.getString(_keyCurrentUser);

    if (userJson == null || userJson.isEmpty) return;

    try {
      final decoded = jsonDecode(userJson);

      if (decoded is Map) {
        currentUser.value = AuthModel.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      currentUser.value = null;
      _prefs.remove(_keyCurrentUser);
    }

    // Prevent inconsistent session state.
    if (!isLoggedIn) {
      currentUser.value = null;
      isDutyActive.value = false;
      isOnBreak.value = false;
    }
  }

  // --------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------

  Future<void> setAuth(String token, AuthModel user) async {
    if (token.isEmpty) {
      throw ArgumentError('Authentication token cannot be empty.');
    }

    final userJson = jsonEncode(user.toJson());

    // Persist first, then update reactive state.
    await _prefs.setString(_keyAuthToken, token);
    await _prefs.setString(_keyCurrentUser, userJson);

    authToken.value = token;
    currentUser.value = user;
  }

  Future<void> updateUser(AuthModel user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));

    currentUser.value = user;
  }

  Future<void> logout() async {
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyCurrentUser);
    await _prefs.remove(_keyIsDutyActive);
    await _prefs.remove(_keyIsOnBreak);

    authToken.value = '';
    currentUser.value = null;
    isDutyActive.value = false;
    isOnBreak.value = false;
  }

  // --------------------------------------------------
  // DUTY / BREAK STATUS
  // --------------------------------------------------

  Future<void> setDutyActive(bool value) async {
    await _prefs.setBool(_keyIsDutyActive, value);
    isDutyActive.value = value;

    if (!value) {
      await _prefs.setBool(_keyIsOnBreak, false);
      isOnBreak.value = false;
    }
  }

  Future<void> setOnBreak(bool value) async {
    await _prefs.setBool(_keyIsOnBreak, value);
    isOnBreak.value = value;
  }

  // --------------------------------------------------
  // THEME & COLOR SCHEME
  // --------------------------------------------------

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.name);
    themeMode.value = mode;
  }

  // --------------------------------------------------
  // STRING PREFERENCES
  // --------------------------------------------------

  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // --------------------------------------------------
  // BOOLEAN PREFERENCES
  // --------------------------------------------------

  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // --------------------------------------------------
  // INTEGER PREFERENCES
  // --------------------------------------------------

  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // --------------------------------------------------
  // GENERAL PREFERENCES
  // --------------------------------------------------

  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// Removes only session-related data.
  Future<void> clearSession() async {
    await logout();
  }

  /// Removes ALL application preferences.
  /// Use carefully because this affects other app settings.
  Future<bool> clearAllPreferences() {
    return _prefs.clear();
  }
}
