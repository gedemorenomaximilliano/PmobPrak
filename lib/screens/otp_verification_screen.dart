import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String role;
  const OtpVerificationScreen({super.key, required this.email, required this.role});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    try {
      await apiService.verifyOTP(widget.email, _otpController.text);
      if (!mounted) return;
      if (widget.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Verification', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                Text('OTP sent to ${widget.email}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading ? const CircularProgressIndicator(color: Colors.white) : GradientButton('Verify', _verify),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
