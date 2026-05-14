import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CareDoseApp());
}

class CareDoseApp extends StatelessWidget {
  const CareDoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareDose',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
