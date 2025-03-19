//lib
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//function
import '../../function/login_with_social.dart';

//widgets
import '../widgets/password_input.dart';
import '../widgets/social_button.dart';




final emailProvider = StateProvider<String?>((ref) => null);
final passwordProvider = StateProvider<String?>((ref) => null);

final hidePasswordProvider = StateProvider<bool>((ref) => true);

final loginLoadingProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends ConsumerState<LoginScreen> {
  _LoginScreen();

  final form = GlobalKey<FormState>();

  void sumbitForm() {
    final bool isValid = form.currentState!.validate();
    if (!isValid) {
      return;
    }

    form.currentState!.save();
  }
  @override
  Widget build(BuildContext context) {
    final hiddenPassword = ref.watch(hidePasswordProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and welcome text
                    Column(
                      children: [
                        const SizedBox(height: 48),
                        Image.asset(
                          'assets/imgs/seup-logo.jpg', // Replace with actual logo path
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'ยินดีต้อนรับกลับมา!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'เข้าสู่ระบบเพื่อเริ่มต้นการสนทนา',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4B5563),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Input fields and sign in button
                    Form(
                      key: form,
                      child: Column(
                        children: [
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'กรอกอีเมล',
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
                                  color: Color(0xFFD1D5DB),
                                  width: 1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              validator: (email) {
                                // Handle email change
                                if (email == null || email.isEmpty) {
                                  return 'กรุณากรอกอีเมล';
                                }
                                return null;
                              },
                            ),

                          const SizedBox(height: 16),

                          // Password input
                          PasswordInput(
                            icon: null,
                            hintText: 'กรอกรหัสผ่าน',
                            isObscured: hiddenPassword,
                            onToggleVisibility: () {
                              // Handle password visibility toggle
                              setState(() {
                                ref.read(hidePasswordProvider.notifier).state =
                                    !ref.read(hidePasswordProvider);
                              });
                            },
                            validator: (password) {
                              // Handle password change
                              if (password == null || password.isEmpty) {
                                return 'กรุณากรอกรหัสผ่าน';
                              }
                              return null;
                            },
                            onSaved: (password) {
                              // Handle password save
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Handle forgot password
                        },
                        child: const Text(
                          'ลืมรหัสผ่าน?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign in button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle sign in
                          sumbitForm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFD1D5DB),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'หรือ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFD1D5DB),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Social login buttons
                    Column(
                      children: [
                        SocialButton(
                          icon: 'assets/icons/google.svg',
                          text: 'เข้าสู่ระบบด้วย Google',
                          onPressed: () {
                            // Handle Google login
                            loginWithSocial('google');
                          },
                        ),
                        const SizedBox(height: 12),
                        SocialButton(
                          icon: 'assets/icons/facebook.svg',
                          text: 'เข้าสู่ระบบด้วย Facebook',
                          onPressed: () {
                            // Handle Facebook login
                            loginWithSocial('facebook');
                          },
                        ),
                        const SizedBox(height: 12),
                        SocialButton(
                          icon: 'assets/icons/line.svg',
                          text: 'เข้าสู่ระบบด้วย LINE',
                          onPressed: () {
                            // Handle LINE login
                            loginWithSocial('line');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Sign up text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'คุณยังไม่มีบัญชี?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // Handle sign up navigation
                            context.go('/signup');
                          },
                          child: const Text(
                            'สร้างบัญชี',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
