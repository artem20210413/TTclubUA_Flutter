import 'dart:convert';

// import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt_club_ua/api/routs/auth.dart';

enum UserRole { admin, editor, user, copywriter, headCopywriter }

/// Maps [UserRole] values to the role strings sent by the backend. Only
/// `headCopywriter` needs an explicit mapping since Dart enum identifiers
/// cannot contain the hyphen in `head-copywriter`; every other role's wire
/// string matches its Dart identifier (`.name`).
extension UserRoleApi on UserRole {
  String get apiName =>
      this == UserRole.headCopywriter ? 'head-copywriter' : name;
}

class UserStorage {
  static SharedPreferences? _prefs;
  static dynamic _userInfo;

  static Future<SharedPreferences> _getPrefs() async {
    // if (_prefs == null) {
    //   _prefs = await SharedPreferences.getInstance();
    // }
    // return _prefs!;

    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> _updatePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyToken = 'userToken';
  static const _keyUserData = 'userData';

  // Сохранить все данные о пользователе
  static Future<void> saveToken(String token) async {
    // final prefs = await SharedPreferences.getInstance();
    final prefs = await _getPrefs();
    await prefs.setString(_keyToken, token);
    // await _updatePrefs();
  }

  // Сохранить все данные о пользователе
  static Future<void> saveUserInfo(Map<String, dynamic> userData) async {
    // print(userData);
    final prefs = await _getPrefs();
    final userDataString = jsonEncode(userData);
    await prefs.setString(_keyUserData, userDataString);

    _userInfo = await getUserInfo();
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await _getPrefs();
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      return jsonDecode(
          userDataString); // Преобразуем JSON строку обратно в Map
    }
    return null;
  }

  // Очистить все данные пользователя
  static Future<void> clearUserInfo() async {
    final token = await getToken();
    if (token != null) await API_LOGOUT(token);

    final prefs = await _getPrefs();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
    _userInfo = null;
  }

  static Future<bool> checkAndUpdate() async {
    final token = await getToken();
    if (token == null) return false;
    final res = await API_AUTH_CHECK(token);
    if (res.statusCode == 200) {
      final resBody = json.decode(res.body);
      await saveUserInfo(resBody['data']['user']);
      // print('token: ' + (token ?? ''));
      return true;
    }

    return false;
  }

  /************** GETERS ************/

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyToken);
  }

  // static Future<String?> getUserId() async {
  //   return _userInfo?['name'];
  // }
  static Future<int?> getId() async {
    return _userInfo?['id'];
  }

  static Future<String?> getTelegramNickname() async {
    return _userInfo?['telegram_nickname'];
  }

  static Future<String?> getInstagramNickname() async {
    return _userInfo?['instagram_nickname'];
  }

  static Future<String?> getBirthDate() async {
    return _userInfo?['birth_date'];
  }

  static Future<String?> getProfileImagee() async {
    return _userInfo?['profile_image'];
  }

  static Future<String?> getUserName() async {
    return _userInfo?['name'];
  }

  static Future<bool> isEntryPaid() async {
    return _userInfo?['is_entry_paid'] ?? true;
  }

  static Future<String?> getUserEmail() async {
    return _userInfo?['email'];
  }

  static Future<String?> getUserPhone() async {
    return _userInfo?['phone'];
  }

  static Future<bool?> getUserActive() async {
    return _userInfo?['active'];
  }

  static Future<String?> getOccupationDescription() async {
    return _userInfo?['occupation_description'];
  }

  static Future<String?> getUpdatedAt() async {
    return _userInfo?['updated_at'];
  }

  static Future<dynamic> getCities() async {
    return _userInfo?['cities'];
  }

  static Future<List<UserRole>> getRoles() async {
    List<dynamic> roleStrings = _userInfo?['roles'] ?? [];

    return UserRole.values
        .where((role) => roleStrings.contains(role.apiName))
        .toList();
  }

//TODO не верно1!!!!
  /// Проверка, есть ли у пользователя одна из указанных ролей
  static Future<bool> whereInRole(List<UserRole> roles) async {
    List<UserRole> userRoles = await getRoles(); // Получаем роли пользователя

    // Проверяем, есть ли пересечение между ролями пользователя и переданными ролями
    return userRoles.any((role) => roles.contains(role));
  }

  static Future<bool> isAdmin() async {
    return await whereInRole([UserRole.admin]);
  }

  /// View/create/edit access in Merch, Partners, Draws (content), Events.
  static Future<bool> canEditContent() async {
    return await whereInRole(
        [UserRole.admin, UserRole.copywriter, UserRole.headCopywriter]);
  }

  /// Delete access in the 4 sections, plus draw-execution actions (start
  /// draw / pick winner / status changes).
  static Future<bool> canDeleteContent() async {
    return await whereInRole([UserRole.admin, UserRole.headCopywriter]);
  }
}
