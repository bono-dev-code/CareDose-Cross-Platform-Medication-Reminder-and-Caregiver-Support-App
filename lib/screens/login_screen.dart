import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await _authService.login(email: _emailController.text, password: _passwordController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pushAndRemoveUntil(context, AppRoutes.fadeSlide(const HomeScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Login')),
      body: CareDoseBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const CareIllustration(size: 145),
                  const SizedBox(height: 14),
                  const Text('Welcome back', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  const SizedBox(height: 8),
                  const Text('Login to continue your medication care plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppTheme.textSoft)),
                  const SizedBox(height: 24),
                  CareCard(
                    child: Column(
                      children: [
                        TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)), validator: (value) => value == null || value.trim().isEmpty ? 'Email is required.' : null),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off))),
                          validator: (value) => value == null || value.isEmpty ? 'Password is required.' : null,
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Login')),
                        const SizedBox(height: 12),
                        TextButton(onPressed: () => Navigator.pushReplacement(context, AppRoutes.fadeSlide(const RegisterScreen())), child: const Text('New user? Create an account')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
