import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

Future<void> storeClientCredentials() async {
  await _storage.write(key: 'CLIENT_NAME', value: 'ETGroundChecklist');
  await _storage.write(
      key: 'CLIENT_SECRET',
      value: 'gnNzdztOPcCHxQwdiMT94q1C7M8N9zIEODQM0SDkvQs=');
}

Future<Map<String, String>> getClientCredentials() async {
  final clientName = await _storage.read(key: 'CLIENT_NAME');
  final clientSecret = await _storage.read(key: 'CLIENT_SECRET');

  if (clientName == null || clientSecret == null) {
    throw Exception('Client credentials are missing.');
  }

  return {
    'CLIENT_NAME': clientName,
    'CLIENT_SECRET': clientSecret,
  };
}
