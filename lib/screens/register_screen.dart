import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await _authService.register(fullName: _nameController.text, email: _emailController.text, password: _passwordController.text, confirmPassword: _confirmPasswordController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully.')));
    Navigator.pushAndRemoveUntil(context, AppRoutes.fadeSlide(const HomeScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Create Account')),
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
                  const CareIllustration(size: 135),
                  const SizedBox(height: 14),
                  const Text('Start your care journey', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  const SizedBox(height: 8),
                  const Text('Create an account so your medication plan, calendar, and history stay private.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppTheme.textSoft)),
                  const SizedBox(height: 24),
                  CareCard(
                    child: Column(
                      children: [
                        TextFormField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)), validator: (value) => value == null || value.trim().length < 2 ? 'Full name is required.' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)), validator: (value) => value == null || value.trim().isEmpty ? 'Email is required.' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _passwordController, obscureText: _hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off))), validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters.' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _confirmPasswordController, obscureText: _hideConfirmPassword, decoration: InputDecoration(labelText: 'Confirm password', prefixIcon: const Icon(Icons.verified_user_outlined), suffixIcon: IconButton(onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword), icon: Icon(_hideConfirmPassword ? Icons.visibility : Icons.visibility_off))), validator: (value) => value == null || value.isEmpty ? 'Confirm your password.' : null),
                        const SizedBox(height: 22),
                        ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Create Account')),
                        const SizedBox(height: 12),
                        TextButton(onPressed: () => Navigator.pushReplacement(context, AppRoutes.fadeSlide(const LoginScreen())), child: const Text('Already have an account? Login')),
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
