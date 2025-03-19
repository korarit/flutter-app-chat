import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


Future<UserCredential> signInWithGoogle() async {
  try {
    // เริ่มกระบวนการ Google Sign-In
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    if (googleUser == null) {
      // ผู้ใช้ยกเลิกการล็อกอิน
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    // ดึงข้อมูลการยืนยันตัวตนจาก Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // สร้าง credential สำหรับ Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // ล็อกอินเข้า Firebase ด้วย credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Error during Google Sign-In: $e');
    rethrow;
  }
}
