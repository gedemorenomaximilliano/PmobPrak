import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_add_item_screen.dart';
import 'screens/explorePlaces.dart';
import 'screens/favorites_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/transaction_history_screen.dart';

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
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: kBlueMid)),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: args['email'],
              role: args['role'],
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),
        '/admin_dashboard': (_) => const AdminDashboard(),
        '/cart': (_) => const CartScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/admin_add_item': (_) => const AdminAddItemScreen(),
        '/explore': (_) => const ExplorePlacesScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/transactions': (_) => const TransactionHistoryScreen(),
      },
    );
  }
}
