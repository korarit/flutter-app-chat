import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';


String _createFakeCustomToken(String userId) {
  // JWT ประกอบด้วย Header.Payload.Signature
  final header = base64UrlEncode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64UrlEncode(utf8.encode('{"uid":"$userId","iss":"fake"}'));
  final fakeSignature = base64UrlEncode(Hmac(sha256, utf8.encode('fake-secret')).convert(utf8.encode('$header.$payload')).bytes);
  return '$header.$payload.$fakeSignature';
}
Future<UserCredential> signInWithLine() async {
  try {
    final result = await LineSDK.instance.login(scopes: ['profile', 'openid', 'email']);
    if (result.userProfile == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    final userId = result.userProfile?.userId;
    if (userId == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    // 2. ขอรับ ID token จาก LINE
    final idToken = result.accessToken.idTokenRaw;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
    
    // 3. เรียกใช้ Cloud Function เพื่อแลกเปลี่ยนเป็น Firebase token
    final callable = FirebaseFunctions.instance.httpsCallable('createFirebaseToken');

    final response = await callable.call({
      'accessToken': result.accessToken.value,
      'idToken': idToken
    });
    
    // 4. ล็อกอินเข้า Firebase ด้วย custom token
    final firebaseToken = response.data['token'];
    final userCredential = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);

    await userCredential.user?.updateDisplayName(result.userProfile?.displayName ?? '');
    if (result.userProfile?.pictureUrl != null) {
      await userCredential.user?.updatePhotoURL(result.userProfile?.pictureUrl);
    }
    final userEmail = result.accessToken.email;
    if (userEmail != null) {
      await userCredential.user?.updateEmail(userEmail, );
    }

    return userCredential;


  } catch (e) {
    print('Error during Line Sign-In: $e');
    rethrow;
  }
}