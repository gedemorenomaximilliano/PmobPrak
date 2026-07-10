import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import '../constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final List<String> _sentences = [
    "Ready for your next adventure?",
    "Banyuwangi is waiting for you!",
    "Pack your bags, explore the wonders.",
    "Making memories, one trip at a time.",
    "Discover the beauty of nature."
  ];
  int _currentSentenceIndex = 0;
  Timer? _timer;

  late AnimationController _bgController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slide1;
  late Animation<Offset> _slide2;
  late Animation<Offset> _slide3;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slide1 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _slide2 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
    ));

    _slide3 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentSentenceIndex =
              (_currentSentenceIndex + 1) % _sentences.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '459391156579-l073a7dh7p1elm4rq52bsmatvh9pgh94.apps.googleusercontent.com',
  );

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password is required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await apiService.login(
          _emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      if (res['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final res = await apiService.googleLogin(idToken);
      if (!mounted) return;

      if (res['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                          const Color(0xFF1976D2),
                          const Color(0xFF0D47A1),
                          _bgController.value)!,
                      Color.lerp(
                          const Color(0xFF0D2B4E),
                          const Color(0xFF1A237E),
                          _bgController.value)!,
                      const Color(0xFF0A1A2B),
                    ],
                    stops: const [0.0, 0.35, 0.7],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),
          ..._buildFloatingIcons(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        SlideTransition(
                          position: _slide1,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [kAccent, Color(0xFFFF8F00)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kAccent.withOpacity(0.4),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.explore,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SlideTransition(
                          position: _slide1,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SlideTransition(
                          position: _slide2,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 800),
                              child: Text(
                                _sentences[_currentSentenceIndex],
                                key: ValueKey(_currentSentenceIndex),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: kAccent,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        SlideTransition(
                          position: _slide2,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildTextField(
                                _emailController,
                                'Email',
                                Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slide3,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildTextField(
                                _passwordController,
                                'Password',
                                Icons.lock_outline,
                                isPassword: true),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SlideTransition(
                          position: _slide3,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : GradientButton('Login', _login),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slide3,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?",
                                    style:
                                        TextStyle(color: Colors.white70)),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SignUpScreen())),
                                  child: const Text('Sign Up',
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: _slide3,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Colors.white
                                            .withOpacity(0.2))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text('Or continue with',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.5),
                                          fontSize: 12)),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: Colors.white
                                            .withOpacity(0.2))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: _slide3,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildGoogleButton(),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _googleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide.none,
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black54))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('G',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4285F4))),
                  SizedBox(width: 12),
                  Text('Sign in with Google',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white60),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white60),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingIcons() {
    final icons = [
      Icons.park,
      Icons.waves,
      Icons.terrain,
      Icons.flight,
      Icons.camera_alt,
      Icons.terrain,
    ];
    final rng = Random(42);
    return List.generate(6, (i) {
      final size = 20.0 + rng.nextDouble() * 16;
      final top = 80.0 + rng.nextDouble() * 400;
      final left = 20.0 + rng.nextDouble() * 300;
      return Positioned(
        top: top,
        left: left,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (_, __) {
            final offset = sin((_bgController.value * pi) + i * 0.8) * 12;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Icon(
                icons[i],
                size: size,
                color: Colors.white.withOpacity(0.04),
              ),
            );
          },
        ),
      );
    });
  }
}
