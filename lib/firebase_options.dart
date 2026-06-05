import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const _placeholder = 'REPLACE_ME';

  static bool get isConfigured {
    return web.apiKey != _placeholder &&
        web.appId != _placeholder &&
        web.messagingSenderId != _placeholder &&
        web.projectId != _placeholder &&
        web.authDomain != 'REPLACE_ME.firebaseapp.com' &&
        web.storageBucket != 'REPLACE_ME.appspot.com';
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError('CampusFix Firebase is configured for web only.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDWMGw_cRiP2zEAmrsku82uuoaVFsFUND0",
    appId: "1:593978553099:web:c1b9416825368b7feaa80e",
    messagingSenderId: "593978553099",
    projectId: "campusfix-81904",
    authDomain: "campusfix-81904.firebaseapp.com",
    storageBucket: "campusfix-81904.firebasestorage.app",
  );
}
