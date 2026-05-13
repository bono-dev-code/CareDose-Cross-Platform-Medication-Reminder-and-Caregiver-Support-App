import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final bool skipOnboardingCheck;
  const WelcomeScreen({super.key, this.skipOnboardingCheck = false});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _authService = AuthService();
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    if (!widget.skipOnboardingCheck) {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('onboarding_seen') ?? false;
      if (!seen && mounted) {
        Navigator.pushReplacement(context, AppRoutes.fadeSlide(const OnboardingScreen()));
        return;
      }
    }
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    if (user != null) {
      Navigator.pushReplacement(context, AppRoutes.fadeSlide(const HomeScreen()));
      return;
    }
    setState(() => _checkingSession = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(body: CareDoseBackground(child: Center(child: CircularProgressIndicator())));
    }

    return Scaffold(
      body: CareDoseBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CareIllustration(size: 190),
                const SizedBox(height: 22),
                const Text('CareDose', textAlign: TextAlign.center, style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -1)),
                const SizedBox(height: 10),
                const Text('Your calm medication companion for daily reminders, adherence tracking, and family care support.', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, height: 1.45, color: AppTheme.textSoft)),
                const SizedBox(height: 34),
                ElevatedButton.icon(onPressed: () => Navigator.push(context, AppRoutes.fadeSlide(const LoginScreen())), icon: const Icon(Icons.login), label: const Text('Login')),
                const SizedBox(height: 14),
                OutlinedButton.icon(onPressed: () => Navigator.push(context, AppRoutes.fadeSlide(const RegisterScreen())), icon: const Icon(Icons.person_add_alt_1), label: const Text('Create New Account')),
                const SizedBox(height: 20),
                const CareCard(
                  padding: EdgeInsets.all(14),
                  child: Text('CareDose supports reminders only. Always follow advice from your doctor or pharmacist.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSoft)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
