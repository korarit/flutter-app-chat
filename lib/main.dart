import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ต้องเพิ่ม import Riverpod
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

import 'firebase_options.dart';


import 'package:flutter_android_chatapp/routing.dart';

void main() async {

  // ต้องเรียก ensureInitialized ก่อนเรียก runApp และ Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LineSDK.instance.setup("2007091112").then((_) {
    print("LineSDK Prepared");
  });

  runApp(
    const ProviderScope( // ✅ ครอบแอปด้วย ProviderScope สำหรับใช้ Riverpod
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      routerConfig: router,
    );
  }
}
