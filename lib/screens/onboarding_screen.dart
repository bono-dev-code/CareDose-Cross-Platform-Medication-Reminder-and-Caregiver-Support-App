import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardingPage(icon: Icons.alarm_rounded, title: 'Never miss medication again', subtitle: 'Get calm reminders with Taken, Snooze, Skip, and Missed tracking.'),
    _OnboardingPage(icon: Icons.calendar_month_rounded, title: 'See your month clearly', subtitle: 'CareDose builds your calendar from the day you start taking medication.'),
    _OnboardingPage(icon: Icons.insights_rounded, title: 'Understand your health routine', subtitle: 'Track adherence, streaks, refill warnings, and medication notes.'),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, AppRoutes.fadeSlide(const WelcomeScreen(skipOnboardingCheck: true)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CareDoseBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _finish, child: const Text('Skip'))),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _index = value),
                    children: _pages,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 26 : 9,
                        height: 9,
                        decoration: BoxDecoration(color: _index == i ? AppTheme.primary : AppTheme.border, borderRadius: BorderRadius.circular(20)),
                      )),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _index == _pages.length - 1
                      ? _finish
                      : () => _controller.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic),
                  child: Text(_index == _pages.length - 1 ? 'Start CareDose' : 'Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CareIllustration(size: 190),
          const SizedBox(height: 28),
          Container(width: 64, height: 64, decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(22)), child: Icon(icon, color: Colors.white, size: 32)),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -.6)),
          const SizedBox(height: 12),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.45, color: AppTheme.textSoft)),
        ],
      ),
    );
  }
}
