import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';
import 'health_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_security_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  final _authService = AuthService();
  String _name = 'CareDose User';
  String _email = 'caredose.user@email.com';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _service.getName();
    final email = await _service.getEmail();
    if (mounted) {
      setState(() {
        _name = name;
        _email = email;
      });
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _service.saveProfile(nameController.text, emailController.text);
              if (!mounted) return;
              Navigator.pop(context);
              await _loadProfile();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, AppRoutes.fadeSlide(const WelcomeScreen()), (route) => false);
  }

  Widget _profileTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return CareCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppTheme.primary)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [IconButton(tooltip: 'Edit profile', onPressed: _editProfile, icon: const Icon(Icons.edit))],
      ),
      body: CareDoseBackground(
        child: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 96, 18, 24),
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Color(0x332B7DE9), blurRadius: 26, offset: Offset(0, 14))]),
              child: Column(children: [
                const CircleAvatar(radius: 54, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppTheme.primary, size: 62)),
                const SizedBox(height: 18),
                Text(_name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text(_email, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(.90))),
              ]),
            ),
            const SizedBox(height: 26),
            _profileTile(icon: Icons.health_and_safety, title: 'Health Profile', onTap: () => Navigator.push(context, AppRoutes.fadeSlide(const HealthProfileScreen()))),
            _profileTile(icon: Icons.notifications, title: 'Notification Settings', onTap: () => Navigator.push(context, AppRoutes.fadeSlide(const NotificationSettingsScreen()))),
            _profileTile(icon: Icons.shield, title: 'Privacy and Security', onTap: () => Navigator.push(context, AppRoutes.fadeSlide(const PrivacySecurityScreen()))),
            _profileTile(icon: Icons.logout, title: 'Logout', onTap: () { _logout(); }),
          ],
        ),
      ),
      ),
    );
  }
}
