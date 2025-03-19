import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  try {
    // Trigger Facebook login
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    // Check if login was successful
    if (loginResult.status == LoginStatus.success) {
      // Get access token
      final AccessToken accessToken = loginResult.accessToken!;
      
      // Create credential for Firebase
      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in to Firebase with the credential
      return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } else {
      print('Facebook login failed: ${loginResult.status}');
      return null;
    }
  } catch (e) {
    print('Error during Facebook login: $e');
    return null;
  }
}
