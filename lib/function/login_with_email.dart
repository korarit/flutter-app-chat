import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> loginWithEmail({
  required String email,
  required String password,
}) async {
  await Future.delayed(const Duration(seconds: 1));
  return null;
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

    FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
      'name': name,
      'email': email,
      'image_url': urlImage,
    });

    if (urlImage != '') {
      await userCredential.user?.updatePhotoURL(urlImage);
    }


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
