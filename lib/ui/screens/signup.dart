import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';  
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

//functions
import 'package:flutter_android_chatapp/function/login_with_email.dart';

//widgets
import 'package:flutter_android_chatapp/ui/widgets/password_input.dart';
import 'package:flutter_android_chatapp/ui/widgets/loading_button.dart';

final _firebaseAuth = FirebaseAuth.instance;

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUp();
}

// for password field visibility toggle state
final hidePasswordProvider = StateProvider<bool>((ref) {
  return true;
});
// for save password field
final passwordProvider = StateProvider<String?>((ref) {
  return null;
});
// for save confirm password field
final confirmPasswordProvider = StateProvider<String?>((ref) {
  return null;
});
// for email field
final emailProvider = StateProvider<String?>((ref) {
  return null;
});
final nameProvider = StateProvider<String?>((ref) {
  return null;
});

// for confirm password field visibility toggle state
final hideConfirmPasswordProvider = StateProvider<bool>((ref) {
  return true;
});
// for profile image file save
final profileImageProvider = StateProvider<File?>((ref) {
  return null;
});
// for error messages to showing to user
final errorMessagesProvider = StateProvider<String?>((ref) {
  return null;
});
// for loading state of sign up button
final isLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

class _SignUp extends ConsumerState<SignUp> {
  void handlePickProfilePhoto() async {
    // get permission to access camera
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      await Permission.camera.request();
    }

    // permission is denied
    if (status.isDenied) {
      return;
    }

    try{
    final picker = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 256,
        maxHeight: 256);
    // Use picker to pick an image
    if (picker != null) {
      ref.read(profileImageProvider.notifier).state = File(picker.path);
    }
    } catch (e) {
      print(e);
    }
  }

  final form = GlobalKey<FormState>();

  void sumbitForm() async {
    final bool isValid = form.currentState!.validate();
    if (!isValid) {
      return;
      
    }
    //check password and confirm password
    form.currentState!.save();

    final email = ref.read(emailProvider);
    final name = ref.read(nameProvider);
    final password = ref.read(passwordProvider);
    final confirmPassword = ref.read(confirmPasswordProvider);

    if (email == null || password == null || confirmPassword == null || name == null) {
      ref.read(errorMessagesProvider.notifier).state = 'กรุณากรอกข้อมูลให้ครบ';
      return;
    }

    // loading state
    ref.read(isLoadingProvider.notifier).state = true;
    final errorMessage = await registerWithEmail(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      profileImage: ref.read(profileImageProvider),
    );
    ref.read(isLoadingProvider.notifier).state = false;

    if (errorMessage != null) {
      ref.read(errorMessagesProvider.notifier).state = errorMessage;
    } else {
      ref.read(errorMessagesProvider.notifier).state = null;

      //reset form
      form.currentState!.reset();

      //reset state
      ref.read(emailProvider.notifier).state = null;
      ref.read(passwordProvider.notifier).state = null;
      ref.read(confirmPasswordProvider.notifier).state = null;
      ref.read(nameProvider.notifier).state = null;
      ref.read(profileImageProvider.notifier).state = null;

      // Navigate to home screen
      if (mounted) {
        GoRouter.of(context).go('/');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32.0),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                padding: const EdgeInsets.all(4.0),
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  weight: 600,
                ),
                onPressed: () {
                  // Navigate back to login screen
                  ref.read(profileImageProvider.notifier).state = null;
                  context.go('/');
                },
              ),
              const SizedBox(width: 12.0),
              const Text(
                'สร้างบัญชีใหม่',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 358),
      child: Column(
        children: [
          _buildProfilePhotoSection(),
          const SizedBox(height: 32.0),
          Form(key: form, child: _buildFormFields()),
          _errorMessageShow(),
          const SizedBox(height: 32.0),
          LoadingButton(
            text: "สมัครสมาชิก", 
            backgroundColor: const Color(0xFF2563EB), 
            onPressed: (){
              sumbitForm();
            }, 
            isLoading: ref.watch(isLoadingProvider),
          ),
          const SizedBox(height: 32.0),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    final profileImage = ref.watch(profileImageProvider);
    return Column(
      children: [
        SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 148,
                height: 148,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: profileImage != null
                    ? CircleAvatar(
                        radius: 48,
                        backgroundImage: FileImage(profileImage),
                      )
                    : const Icon(
                        Icons.person_outline,
                        size: 48,
                        color: Color(0xFF6B7280),
                      ),
              ),
              Positioned(
                  bottom: -8,
                  right: -8,
                  child: IconButton(
                    onPressed: () {
                      // Handle profile photo logic
                      handlePickProfilePhoto();
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      alignment: Alignment.center,
                      side: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 1,
                      ),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 24, // ลดขนาดไอคอนให้พอดีกับปุ่ม
                      color: Colors.white,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                      maxWidth: 36,
                      maxHeight: 36,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        const Text(
          'เพิ่มรูปภาพโปรไฟล์',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    final hidePassword = ref.watch(hidePasswordProvider);
    final hideConfirmPassword = ref.watch(hideConfirmPasswordProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          label: 'ชื่อ',
          hintText: 'กรอกชื่อของคุณ',
          keyboardType: TextInputType.emailAddress,
          suffixIcon: const Icon(Icons.email_outlined, size: 20),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกชื่อ';
            }
            return null;
          },
          onSaved: (value) => ref.read(nameProvider.notifier).state = value,
        ),
        const SizedBox(height: 12.0),
        _buildInputField(
          label: 'อีเมล',
          hintText: 'กรอกอีเมลของคุณ',
          keyboardType: TextInputType.emailAddress,
          suffixIcon: const Icon(Icons.email_outlined, size: 20),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกอีเมล';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'อีเมลไม่ถูกต้อง';
            }
            return null;
          },
          onSaved: (value) => ref.read(emailProvider.notifier).state = value,
        ),
        const SizedBox(height: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รหัสผ่าน',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4.0),
            PasswordInput(
              icon: Icons.lock_outline,
              hintText: 'กรอกรหัสผ่าน',
              isObscured: hidePassword,
              onToggleVisibility: () {
                setState(() {
                  ref.read(hidePasswordProvider.notifier).state =
                      !ref.read(hidePasswordProvider);
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกรหัสผ่าน';
                }
                if (value.length < 6) {
                  return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                }
                return null;
              },
              onSaved: (value) => ref.read(passwordProvider.notifier).state = value,
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ยืนยันรหัสผ่าน',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4.0),
            PasswordInput(
              icon: Icons.lock_outline,
              hintText: 'กรอกยืนยันรหัสผ่าน',
              isObscured: hideConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  ref.read(hideConfirmPasswordProvider.notifier).state =
                      !ref.read(hideConfirmPasswordProvider);
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกยืนยันรหัสผ่าน';
                }
                if (value.length < 6) {
                  return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                }
                return null;
              },
              onSaved: (value) => ref.read(confirmPasswordProvider.notifier).state = value,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required  FormFieldValidator<String>? validator,
    required void Function(String?) onSaved,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 139, 162, 199),
          ),
        ),
        const SizedBox(height: 2.0),
        TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFFADAEBC),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: suffixIcon,
          ),
          validator: validator,
          onSaved: onSaved,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'คุณมีบัญชีอยู่แล้ว?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(width: 8.0),
        GestureDetector(
          onTap: () {
            // Navigate to login screen
            context.go('/');
          },
          child: const Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorMessageShow() {
    final errorMessage = ref.watch(errorMessagesProvider);
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12.0),
        Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
