import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static bool get isConfigured {
    return _apiKey.isNotEmpty &&
        _appId.isNotEmpty &&
        _messagingSenderId.isNotEmpty &&
        _projectId.isNotEmpty &&
        _authDomain.isNotEmpty &&
        _storageBucket.isNotEmpty;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError('CampusFix Firebase is configured for web only.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: _authDomain,
    storageBucket: _storageBucket,
  );
}
