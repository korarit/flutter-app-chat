import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'firebase_options.dart';

import 'package:flutter_android_chatapp/routing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  await LineSDK.instance.setup("2007091112").then((_) {
    print("LineSDK Prepared");
  });
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // ใช้ routerProvider

    return MaterialApp.router(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      routerConfig: router,
    );
  }
}