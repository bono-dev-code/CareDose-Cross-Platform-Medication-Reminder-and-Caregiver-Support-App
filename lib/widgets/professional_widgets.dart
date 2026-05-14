import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppRoutes {
  static PageRouteBuilder<T> fadeSlide<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.04, 0.04), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class CareDoseBackground extends StatelessWidget {
  final Widget child;
  const CareDoseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
          Positioned(top: -90, right: -70, child: _SoftBlob(size: 220, color: AppTheme.primary.withOpacity(.09))),
          Positioned(bottom: -100, left: -80, child: _SoftBlob(size: 260, color: AppTheme.teal.withOpacity(.08))),
          child,
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _SoftBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Offset beginOffset;

  const AnimatedEntrance({super.key, required this.child, this.index = 0, this.duration = const Duration(milliseconds: 520), this.beginOffset = const Offset(0, .08)});

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(curve);
    Future.delayed(Duration(milliseconds: 65 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  const PressableScale({super.key, required this.child, this.onTap, this.borderRadius});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class CareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  const CareCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.margin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.card.withOpacity(0.98),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressableScale(onTap: onTap, borderRadius: BorderRadius.circular(AppTheme.radius), child: card);
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
          if (actionText != null && onAction != null) TextButton(onPressed: onAction, child: Text(actionText!)),
        ],
      ),
    );
  }
}

class PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const PillBadge({super.key, required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 17, color: color), const SizedBox(width: 6), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5))]),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  const EmptyStateCard({super.key, required this.title, required this.subtitle, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      child: CareCard(
        child: Column(
          children: [
            const CareIllustration(size: 132),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSoft, fontSize: 15, height: 1.45)),
            const SizedBox(height: 18),
            ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

class AnimatedProgressRing extends StatelessWidget {
  final int percentage;
  final double size;
  final Color color;
  const AnimatedProgressRing({super.key, required this.percentage, this.size = 74, this.color = AppTheme.success});

  @override
  Widget build(BuildContext context) {
    final value = percentage.clamp(0, 100) / 100.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(width: size, height: size, child: CircularProgressIndicator(value: animatedValue, strokeWidth: 8, backgroundColor: AppTheme.border, color: color, strokeCap: StrokeCap.round)),
            Text('${(animatedValue * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
          ],
        );
      },
    );
  }
}

class AnimatedCareFab extends StatefulWidget {
  final VoidCallback onPressed;
  const AnimatedCareFab({super.key, required this.onPressed});

  @override
  State<AnimatedCareFab> createState() => _AnimatedCareFabState();
}

class _AnimatedCareFabState extends State<AnimatedCareFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * .035);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.24), blurRadius: 22 + (_controller.value * 8), offset: const Offset(0, 12))]),
            child: child,
          ),
        );
      },
      child: FloatingActionButton.extended(onPressed: widget.onPressed, icon: const Icon(Icons.add), label: const Text('Add Medicine')),
    );
  }
}

class CareIllustration extends StatefulWidget {
  final double size;
  const CareIllustration({super.key, this.size = 180});

  @override
  State<CareIllustration> createState() => _CareIllustrationState();
}

class _CareIllustrationState extends State<CareIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final float = math.sin(_controller.value * math.pi) * 8;
        return SizedBox(
          height: size,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: size, height: size, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.softHeroGradient)),
              Positioned(top: size * .13 + float * .15, child: Container(width: size * .45, height: size * .45, decoration: BoxDecoration(color: const Color(0xFFFFD5B3), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.12), blurRadius: 16)]))),
              Positioned(top: size * .18 + float * .10, child: Container(width: size * .52, height: size * .22, decoration: BoxDecoration(color: AppTheme.primaryDark, borderRadius: BorderRadius.circular(size * .14)))),
              Positioned(bottom: size * .16 - float * .10, child: Container(width: size * .75, height: size * .50, decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(size * .20), boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.20), blurRadius: 22, offset: const Offset(0, 10))]), child: Icon(Icons.favorite_rounded, color: Colors.white.withOpacity(.92), size: size * .20))),
              Positioned(right: size * .08, bottom: size * .18 + float, child: _FloatingIcon(size: size * .31, icon: Icons.medication_rounded, color: AppTheme.teal)),
              Positioned(left: size * .08, top: size * .52 - float, child: _FloatingIcon(size: size * .25, icon: Icons.notifications_active_rounded, color: AppTheme.primary)),
              Positioned(top: size * .31 + float * .08, child: Row(mainAxisSize: MainAxisSize.min, children: [_Eye(size: size * .035), SizedBox(width: size * .10), _Eye(size: size * .035)])),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;
  const _FloatingIcon({required this.size, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size * .35), boxShadow: AppTheme.softShadow), child: Icon(icon, color: color, size: size * .52));
  }
}

class _Eye extends StatelessWidget {
  final double size;
  const _Eye({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: const BoxDecoration(color: AppTheme.textDark, shape: BoxShape.circle));
  }
}
