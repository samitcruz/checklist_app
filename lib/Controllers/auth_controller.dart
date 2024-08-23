import 'dart:convert';
import 'package:get/get.dart';
import 'package:safety_check/models/authentication.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  Rxn<User> _user = Rxn<User>();
  final _storage = FlutterSecureStorage();

  User? get user => _user.value;

  bool get isAuthenticated => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() async {
    final idToken = (await _storage.read(key: 'idToken'))?.trim();
    final refreshToken = (await _storage.read(key: 'refreshToken'))?.trim();
    final userIdStr = await _storage.read(key: 'userId');
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    final firstName = await _storage.read(key: 'firstName');
    final lastName = await _storage.read(key: 'lastName');
    final isSuperAdminStr = await _storage.read(key: 'isSuperAdmin');
    final isAdminStr = await _storage.read(key: 'isAdmin');
    final expiryDateStr = await _storage.read(key: 'expiryDate');
    final rolesJson = await _storage.read(key: 'roles');
    final organizationsJson = await _storage.read(key: 'organizations');

    final int? userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    final bool isSuperAdmin = isSuperAdminStr == 'true';
    final bool isAdmin = isAdminStr == 'true';
    final DateTime expiryDate =
        expiryDateStr != null ? DateTime.parse(expiryDateStr) : DateTime.now();
    print('idToken: $idToken');
    print('userId: $userIdStr');
    print('username: $username');
    print('email: $email');
    print('firstname: $firstName');
    print('rolesJson: $rolesJson');
    print('organizationsJson: $organizationsJson');

    List<Role> roles = [];
    if (rolesJson != null) {
      final List<dynamic> rolesList = json.decode(rolesJson);
      roles = rolesList.map((roleJson) => Role.fromJson(roleJson)).toList();
    }

    List<Organization> organizations = [];
    if (organizationsJson != null) {
      final List<dynamic> organizationsList = json.decode(organizationsJson);
      organizations = organizationsList
          .map((orgJson) => Organization.fromJson(orgJson))
          .toList();
    }

    if (idToken != null) {
      _user.value = User(
        id: userId ?? 0,
        username: username ?? '',
        email: email ?? '',
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        idToken: idToken,
        refreshToken: refreshToken ?? '',
        isSuperAdmin: isSuperAdmin,
        isAdmin: isAdmin,
        roles: roles,
        organizations: organizations,
        expiryDate: expiryDate,
      );
    } else {
      _user.value = null;
    }

    print(isAuthenticated);
  }

  void login(User user) {
    _user.value = user;
  }

  void logout() {
    _user.value = null;
  }
}
