import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const JejakBanyuwangiApp());
}

class JejakBanyuwangiApp extends StatelessWidget {
  const JejakBanyuwangiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jejak Banyuwangi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

const Color kBlueLight = Color(0xFF64B5F6);
const Color kBlueMid = Color(0xFF1E88E5);
const Color kBlueDark = Color(0xFF0D47A1);
const Color kNavyDark = Color(0xFF0A1628);
const Color kNavyMid = Color(0xFF112240);
const Color kAccent = Color(0xFFFFC107);
const Color kSkyBlue = Color(0xFF5BB8F5);

class _FieldIcon extends StatelessWidget {
  final _FieldIconType type;
  const _FieldIcon(this.type);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: CustomPaint(
        size: const Size(22, 22),
        painter: _FieldIconPainter(type),
      ),
    );
  }
}

enum _FieldIconType { person, lock, email, visibility, visibilityOff }

class _FieldIconPainter extends CustomPainter {
  final _FieldIconType type;
  const _FieldIconPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case _FieldIconType.person:
        canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.22, p);
        final sh = Path()
          ..moveTo(w * 0.06, h * 0.96)
          ..quadraticBezierTo(w * 0.06, h * 0.60, w * 0.50, h * 0.58)
          ..quadraticBezierTo(w * 0.94, h * 0.60, w * 0.94, h * 0.96);
        canvas.drawPath(sh, p);
        break;

      case _FieldIconType.email:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.04, h * 0.20, w * 0.92, h * 0.60),
            const Radius.circular(3),
          ),
          p,
        );
        final v = Path()
          ..moveTo(w * 0.04, h * 0.20)
          ..lineTo(w * 0.50, h * 0.58)
          ..lineTo(w * 0.96, h * 0.20);
        canvas.drawPath(v, p);
        break;

      case _FieldIconType.lock:
        final shackle = Path()
          ..moveTo(w * 0.28, h * 0.46)
          ..lineTo(w * 0.28, h * 0.28)
          ..quadraticBezierTo(w * 0.28, h * 0.06, w * 0.50, h * 0.06)
          ..quadraticBezierTo(w * 0.72, h * 0.06, w * 0.72, h * 0.28)
          ..lineTo(w * 0.72, h * 0.46);
        canvas.drawPath(shackle, p);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.14, h * 0.44, w * 0.72, h * 0.50),
            const Radius.circular(4),
          ),
          p,
        );
        canvas.drawCircle(
          Offset(w * 0.50, h * 0.68),
          w * 0.07,
          Paint()
            ..color = Colors.grey
            ..style = PaintingStyle.fill,
        );
        break;

      case _FieldIconType.visibility:
        final eye = Path()
          ..moveTo(w * 0.04, h * 0.50)
          ..quadraticBezierTo(w * 0.50, h * 0.06, w * 0.96, h * 0.50)
          ..quadraticBezierTo(w * 0.50, h * 0.94, w * 0.04, h * 0.50);
        canvas.drawPath(eye, p);
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.16, p);
        break;

      case _FieldIconType.visibilityOff:
        final eye = Path()
          ..moveTo(w * 0.04, h * 0.50)
          ..quadraticBezierTo(w * 0.50, h * 0.06, w * 0.96, h * 0.50)
          ..quadraticBezierTo(w * 0.50, h * 0.94, w * 0.04, h * 0.50);
        canvas.drawPath(eye, p);
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.16, p);
        canvas.drawLine(
          Offset(w * 0.14, h * 0.14),
          Offset(w * 0.86, h * 0.86),
          p,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_FieldIconPainter old) => old.type != type;
}

class _StarIcon extends StatelessWidget {
  final double size;
  final Color color;
  const _StarIcon({this.size = 14, this.color = kAccent});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star, size: size, color: color);
  }
}

class _ArrowRightIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _ArrowRightIcon({required this.color, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward_ios, size: size, color: color);
  }
}

enum _NavIconType { home, cart, search, heart, person }

class _NavIcon extends StatelessWidget {
  final _NavIconType type;
  final Color color;
  final double size;
  const _NavIcon(this.type, this.color, {this.size = 24});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (type) {
      case _NavIconType.home:
        iconData = Icons.home_outlined;
        break;
      case _NavIconType.cart:
        iconData = Icons.shopping_cart_outlined;
        break;
      case _NavIconType.search:
        iconData = Icons.search;
        break;
      case _NavIconType.heart:
        iconData = Icons.favorite_border;
        break;
      case _NavIconType.person:
        iconData = Icons.person_outline;
        break;
    }
    return Icon(iconData, color: color, size: size);
  }
}

class _CoinIcon extends StatelessWidget {
  final double size;
  const _CoinIcon({this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.attach_money, color: Colors.white, size: size);
  }
}

class _MenuIcon extends StatelessWidget {
  final double size;
  const _MenuIcon({this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.menu, color: Colors.white, size: size);
  }
}

class _LandscapePainter extends CustomPainter {
  final Color color;
  const _LandscapePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.08, size.height * 0.80)
        ..lineTo(size.width * 0.38, size.height * 0.30)
        ..lineTo(size.width * 0.60, size.height * 0.55)
        ..lineTo(size.width * 0.74, size.height * 0.38)
        ..lineTo(size.width * 0.92, size.height * 0.80)
        ..close(),
      p,
    );
    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.26),
      size.width * 0.10,
      p,
    );
  }

  @override
  bool shouldRepaint(_LandscapePainter old) => old.color != color;
}

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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imgH,
            child: ClipPath(
              clipper: _SplashImageClipper(),
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _gradientBox(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imgH,
            child: ClipPath(
              clipper: _SplashImageClipper(),
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
                    'assets/images/logo.png',
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
          Positioned(
            top: imgH - 14,
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
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
                        children: List.generate(3, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == 1 ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == 1
                                  ? kBlueMid
                                  : Colors.blueGrey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5BAEE0), Color(0xFF1565C0)],
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
                                borderRadius: BorderRadius.circular(18),
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

class _SplashImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 44,
      0,
      size.height - 60,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_SplashImageClipper old) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), kSkyBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 32, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello !',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Experience a\nBreathtaking Adventure',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _textField('Username', _FieldIconType.person),
                        const SizedBox(height: 14),
                        _textField(
                          'Password',
                          _FieldIconType.lock,
                          obscure: _obscurePassword,
                          isObscured: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _gradientButton(
                          'Login',
                          () => Navigator.pushNamed(context, '/home'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Or Login with',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialBtn(
                              color: Colors.black,
                              child: const FaIcon(
                                FontAwesomeIcons.apple,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            _socialBtn(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.google,
                                color: Color(0xFF4285F4),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            _socialBtn(
                              color: const Color(0xFF1877F2),
                              child: const FaIcon(
                                FontAwesomeIcons.facebookF,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/signup'),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: kBlueMid,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    String hint,
    _FieldIconType iconType, {
    bool obscure = false,
    bool? isObscured,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: _FieldIcon(iconType),
          suffixIcon: onToggle != null
              ? GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomPaint(
                      size: const Size(22, 22),
                      painter: _FieldIconPainter(
                        isObscured == true
                            ? _FieldIconType.visibilityOff
                            : _FieldIconType.visibility,
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5BAEE0), Color(0xFF1565C0)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kBlueMid.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialBtn({
    required Color color,
    required Widget child,
    BoxBorder? border,
  }) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

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
              _field('Email or Telp', _FieldIconType.email),
              const SizedBox(height: 14),
              _field('Username', _FieldIconType.person),
              const SizedBox(height: 14),
              _field(
                'Password',
                _FieldIconType.lock,
                obscure: _obscurePw,
                isObscured: _obscurePw,
                onToggle: () => setState(() => _obscurePw = !_obscurePw),
              ),
              const SizedBox(height: 14),
              _field(
                'Confirm Password',
                _FieldIconType.lock,
                obscure: _obscureConfirm,
                isObscured: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5BAEE0), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kBlueMid.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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

  Widget _field(
    String hint,
    _FieldIconType iconType, {
    bool obscure = false,
    bool? isObscured,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: _FieldIcon(iconType),
          suffixIcon: onToggle != null
              ? GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomPaint(
                      size: const Size(22, 22),
                      painter: _FieldIconPainter(
                        isObscured == true
                            ? _FieldIconType.visibilityOff
                            : _FieldIconType.visibility,
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Kawah Ijen',
      'rating': 4.9,
      'reviews': 455,
      'price': 'IDR 500K/pax',
      'image':
          'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=640&q=80',
      'desc':
          'Ijen Crater is a majestic volcanic wonder famous for its '
          'turquoise acid lake and the rare, electric blue fire. '
          'A highlight of "The Sunrise of Java".',
    },
    {
      'name': 'Green Bay',
      'rating': 4.9,
      'reviews': 455,
      'price': 'IDR 350K/pax',
      'image':
          'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=640&q=80',
      'desc':
          'A pristine hidden beach surrounded by lush green hills and '
          'crystal-clear turquoise waters. Only reachable by a scenic jungle trek.',
    },
    {
      'name': 'Baluran',
      'rating': 4.7,
      'reviews': 320,
      'price': 'IDR 200K/pax',
      'image':
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=640&q=80',
      'desc':
          'Known as "Africa van Java" for its stunning open savanna. '
          'Home to wild bulls, peacocks, and deer roaming freely.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            stops: [0.0, 0.28, 0.58],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroText(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Best Destination'),
                      const SizedBox(height: 14),
                      _buildCards(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Popular Tours'),
                      const SizedBox(height: 14),
                      _buildList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA000),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.attach_money, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text(
                  'Indah',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Icon(Icons.menu, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildHeroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(height: 1.25),
          children: [
            TextSpan(
              text: 'Discover the\n',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: 'Beauty of ',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: 'Banyuwangi',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF42A5F5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCards() {
    return SizedBox(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: _destinations.length,
        itemBuilder: (_, i) => _DestinationCard(destination: _destinations[i]),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _destinations.length,
      itemBuilder: (_, i) {
        final d = _destinations[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B3E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  d['image'],
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF2C3E50).withOpacity(0.3),
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 36,
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFF2C3E50).withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFA000),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${d['rating']}  •  ${d['price']}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d['desc'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 14,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final icons = [
      Icons.home,
      Icons.shopping_cart,
      Icons.search,
      Icons.favorite,
      Icons.person,
    ];

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final isSelected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF42A5F5)
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icons[i],
                color: isSelected ? Colors.white : Colors.white38,
                size: 24,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final Map<String, dynamic> destination;
  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Image.network(
              destination['image'],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2C3E50).withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.landscape, color: Colors.white54, size: 48),
                ),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF2C3E50).withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFA000),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${destination['rating']} (${destination['reviews']} Review)',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFFA000),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      destination['desc'],
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      destination['price'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
