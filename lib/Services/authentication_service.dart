import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:safety_check/models/authentication.dart';

class AuthenticationService {
  final _storage = FlutterSecureStorage();
  final String _baseUrl =
      'https://api-dev-iam.ethiopianairlines.com/iam-service/api/v1';

  Future<User?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/User/login');
    final accessToken = (await _storage.read(key: 'clientAccessToken'))?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      print('Access token is missing or empty');
      return null;
    }
    print('Using access token: $accessToken');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accessToken': '$accessToken',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        User user = User.fromJson(jsonResponse);

        await _storage.write(key: 'idToken', value: user.idToken);
        await _storage.write(key: 'refreshToken', value: user.refreshToken);

        return user;
      } else {
        print('Failed to log in. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  Future<ClientAuthResponse?> authenticateClient(
      String clientId, String clientSecret) async {
    final url = Uri.parse('$_baseUrl/Client/Login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'clientId': clientId,
          'clientSecret': clientSecret,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        ClientAuthResponse clientAuthResponse =
            ClientAuthResponse.fromJson(jsonResponse);

        await _storage.write(
            key: 'clientAccessToken', value: clientAuthResponse.accessToken);
        await _storage.write(
            key: 'clientRefreshToken', value: clientAuthResponse.refreshToken);

        return clientAuthResponse;
      } else {
        print(
            'Failed to authenticate client. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error authenticating client: $e');
      return null;
    }
  }

  Future<String?> getUserToken() async {
    return await _storage.read(key: 'idToken');
  }

  Future<String?> getClientToken() async {
    return await _storage.read(key: 'clientAccessToken');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'idToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'clientAccessToken');
    await _storage.delete(key: 'clientRefreshToken');
  }
}
