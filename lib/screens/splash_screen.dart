import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    try {
      final loggedIn = await apiService.isLoggedIn();
      if (!loggedIn) {
        if (mounted) setState(() => _checkingSession = false);
        return;
      }
      // Token exists — verify it's still valid
      try {
        final user = await apiService.getUserProfile();
        if (!mounted) return;
        final role = user['role'] as String? ?? 'user';
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (_) {
        // Token invalid or expired — clear and show login
        await apiService.clearToken();
        if (mounted) setState(() => _checkingSession = false);
      }
    } catch (_) {
      if (mounted) setState(() => _checkingSession = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final imgH = size.height * 0.56;

    return Scaffold(
      backgroundColor: const Color(0xFFD6EAF8),
      body: Stack(
        children: [
          // Hero image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imgH,
            child: ClipPath(
              clipper: _SplashClipper(),
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _gradientBox(),
              ),
            ),
          ),
          // Image overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imgH,
            child: ClipPath(
              clipper: _SplashClipper(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.30),
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // Logo & title
          Positioned(
            top: topPad + 12,
            left: 0,
            right: 0,
            height: imgH - topPad - 60,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Image.asset(
                    'assets/images/icon.png',
                    width: 120,
                    height: 130,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jejak\nBanyuwangi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom content
          Positioned(
            top: imgH - 14,
            left: 0,
            right: 0,
            bottom: 0,
            child: _checkingSession
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF1565C0)),
                        SizedBox(height: 12),
                        Text('Checking session…',
                            style: TextStyle(color: Color(0xFF0D2B4E))),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                        child: Column(
                          children: [
                            const Text(
                              'Life Is short and the\nworld is wide',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D2B4E),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Discover the breathtaking beauty of Banyuwangi — '
                              'volcanic craters, pristine beaches, and lush forests await your adventure.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.blueGrey[400],
                                height: 1.6,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == 1 ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == 1
                                        ? kBlueMid
                                        : Colors.blueGrey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5BAEE0),
                                      Color(0xFF1565C0)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kBlueMid.withOpacity(0.40),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/login'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _gradientBox() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0D2B4E), Color(0xFF1565C0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}

class _SplashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - 60)
    ..quadraticBezierTo(size.width * 0.5, size.height + 44, 0, size.height - 60)
    ..close();

  @override
  bool shouldReclip(_SplashClipper old) => false;
}
