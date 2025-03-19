import 'package:go_router/go_router.dart';

import 'package:flutter_android_chatapp/ui/screens/login.dart';
import 'package:flutter_android_chatapp/ui/screens/signup.dart';



final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUp(),
    ),
  ]
);