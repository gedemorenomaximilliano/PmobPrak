import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePw = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF90CAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                'Email or Telp',
                FieldIconType.email,
                bgColor: Colors.white,
                hasShadow: true,
              ),
              const SizedBox(height: 14),
              AppTextField(
                'Username',
                FieldIconType.person,
                bgColor: Colors.white,
                hasShadow: true,
              ),
              const SizedBox(height: 14),
              AppTextField(
                'Password',
                FieldIconType.lock,
                obscure: _obscurePw,
                isObscured: _obscurePw,
                onToggle: () => setState(() => _obscurePw = !_obscurePw),
                bgColor: Colors.white,
                hasShadow: true,
              ),
              const SizedBox(height: 14),
              AppTextField(
                'Confirm Password',
                FieldIconType.lock,
                obscure: _obscureConfirm,
                isObscured: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                bgColor: Colors.white,
                hasShadow: true,
              ),
              const SizedBox(height: 32),
              GradientButton(
                'Sign Up',
                () => Navigator.pushNamed(context, '/home'),
                height: 54,
                radius: 16,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF0A1628),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
