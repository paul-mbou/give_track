import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/app.dart';
import 'package:give_track/core/constants/app_constants.dart';
import 'package:give_track/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final webClientId = AppConstants.googleSignInServerClientId.trim();
  if (webClientId.isEmpty) {
    await GoogleSignIn.instance.initialize();
  } else {
    await GoogleSignIn.instance.initialize(serverClientId: webClientId);
  }
  runApp(const ProviderScope(child: GiveTrackApp()));
}
