import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//function
import 'package:flutter_android_chatapp/function/notification.dart';

Future<String?> loginWithEmail({
  required String email,
  required String password,
}) async {
  try{
  final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = userCredential.user;

  if (user == null) {
    return 'ไม่พบผู้ใช้งาน';
  }

  final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  final String? fcmToken = await NotificationService.instance.getFCMToken();

  if (userData.exists) {
    //update fcm token
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcm': fcmToken,
    });

    return null;
  }

  return null;

  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'ไม่พบผู้ใช้งาน';
    } else if (e.code == 'wrong-password') {
      return 'รหัสผ่านไม่ถูกต้อง';
    } else if (e.code == 'invalid-credential') {
      return 'อีเมลไม่ถูกต้อง';
    } else {
      return 'เกิดข้อผิดพลาดในการล็อกอิน';
    }
  }
}

final _firebaseAuth = FirebaseAuth.instance;

Future<String?> registerWithEmail({
  required String email,
  required String password,
  required String confirmPassword,
  required String name,
  File? profileImage,
}) async {
  if (password != confirmPassword) {
    return 'รหัสผ่านไม่ตรงกัน';
  }

  // Handle sign up logic
  try {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('User created: ${userCredential.user?.email}');

    await userCredential.user?.updateDisplayName(name);

    var urlImage = '';

    if (profileImage != null) {
      final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child('${userCredential.user?.uid}.jpg');
      await storageRef.putFile(profileImage);
      urlImage = await storageRef.getDownloadURL();
    }

    print('test uid: ${userCredential.user?.uid}');

    final String? fcmToekn = await NotificationService.instance.getFCMToken();

    //check if user is new

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
      'name': name,
      'email': email,
      'image_url': urlImage,
      'fcm': fcmToekn,
    });

    if (urlImage != '') {
      await userCredential.user?.updatePhotoURL(urlImage);
    }

    await NotificationService.instance.subscribeToTopic('default');


    return null;

  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      return 'อีเมลนี้มีผู้ใช้งานแล้ว';
    } else {
      return 'เกิดข้อผิดพลาดในการสร้างบัญชีผู้ใช้';
    }
  } on FirebaseException catch (e) {
    print(e);
    return 'เกิดข้อผิดพลาดในการสร้างบัญชีผู้ใช้';
  } on FirebaseFirestore catch (e) {
    print(e);
    return 'เกิดข้อผิดพลาดในการสร้างบัญชีผู้ใช้';
  }
}
