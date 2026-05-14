import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'professional_widgets.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final number = int.tryParse(value);
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .92, end: 1),
              duration: const Duration(milliseconds: 620),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 14),
            if (number != null)
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: number),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, _) => Text('$animatedValue', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.6)),
              )
            else
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.6)),
            const SizedBox(height: 3),
            Text(title, style: const TextStyle(color: AppTheme.textSoft, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
