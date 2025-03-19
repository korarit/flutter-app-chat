import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'provider/facebook.dart';
import 'provider/google.dart';
import 'provider/line.dart';


// สร้าง function สำหรับเลือกการล็อกอิน
Future<void> loginWithSocial(String provider) async {
  final UserCredential? userCredential;
  switch (provider) {
    case "google":
      userCredential = await signInWithGoogle();
      break;
    case "facebook":
      userCredential = await signInWithFacebook();
      break;
    case "line":
      userCredential = await signInWithLine();
      break;
    default:
      userCredential = null;
  }

  if (userCredential == null) {
    throw FirebaseAuthException(
      code: 'ERROR_ABORTED_BY_USER',
      message: 'Sign in aborted by user',
    );
  }

  //check if user is new
  final User? user = userCredential.user;
  final DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

  if (!userDoc.exists) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': user.displayName,
      'email': user.email,
      'image_url': user.photoURL,
    });
  }
}