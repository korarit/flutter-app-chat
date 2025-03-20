import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_android_chatapp/provider/auth_provider.dart';
import 'package:flutter_android_chatapp/ui/screens/login.dart';
import 'package:flutter_android_chatapp/ui/screens/signup.dart';
import 'package:flutter_android_chatapp/ui/screens/home.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    redirect: (context, state) {
      final user = ref.read(authStateProvider).value;
      final currentLocation = state.matchedLocation; // ป้องกัน null
      final isOnLogin = currentLocation == '/login';
      final isOnSignup = currentLocation == '/signup';

      print("Redirect check - User: $user, Location: $currentLocation");

      if (user == null && !isOnLogin && !isOnSignup) {
        return '/login';
      }
      if (user != null && (isOnLogin || isOnSignup)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUp(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}