import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.bodyBuilder, this.currentIndex});
  final WidgetBuilder bodyBuilder;
  final int? currentIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> with TickerProviderStateMixin {
  late int _index;
  AnimationController? _animationController;
  AnimationController? _chatButtonController;

  @override
  void initState() {
    super.initState();
    _index = widget.currentIndex ?? 0;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _chatButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _chatButtonController?.dispose();
    super.dispose();
  }

  void _go(int i) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Always update the index to ensure proper highlighting
    setState(() => _index = i);

    _animationController?.forward().then((_) {
      _animationController?.reverse();
    });

    if (i == 2) {
      _chatButtonController?.forward().then((_) {
        _chatButtonController?.reverse();
      });
    }

    switch (i) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/insights');
        break;
      case 2:
        Navigator.of(context).pushNamed('/enhanced-chat');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/journal');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  void didUpdateWidget(RootShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.currentIndex ?? 0;
    final oldIndex = oldWidget.currentIndex ?? 0;
    if (oldIndex != newIndex) {
      setState(() => _index = newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Return a simple scaffold if controllers aren't initialized yet
    if (_animationController == null || _chatButtonController == null) {
      return Scaffold(
        body: widget.bodyBuilder(context),
        extendBody: true,
        bottomNavigationBar: Container(
          height: 77,
          color: scheme.surface,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: widget.bodyBuilder(context),
      extendBody: true,
      bottomNavigationBar: _EnhancedBottomBar(
        selectedIndex: _index,
        onTap: _go,
        colorScheme: scheme,
        animationController: _animationController!,
        chatButtonController: _chatButtonController!,
      ),
    );
  }
}

class _EnhancedChatButton extends StatelessWidget {
  const _EnhancedChatButton({
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.animationController,
  });

  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final scale = 1.0 + (animationController.value * 0.1);
        final rotation = animationController.value * 0.1;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selected
                        ? [colorScheme.primary, colorScheme.secondary]
                        : [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: selected ? 20 : 16,
                      offset: const Offset(0, 8),
                      spreadRadius: selected ? 2 : 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated background pulse
                    if (selected)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    // Chat icon with subtle animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: selected ? 1 : 0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 28 + (value * 4),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedNotchPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final bool isDark;

  _EnhancedNotchPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Main background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Subtle border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final path = Path();
    const double notchRadius = 45.0;
    const double cornerRadius = 20.0;
    final double centerX = size.width / 2;

    // Start from bottom left with rounded corner
    path.moveTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Left side up with rounded corner
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top edge to notch start
    path.lineTo(centerX - notchRadius - 5, 0);

    // Smooth transition into notch
    path.quadraticBezierTo(centerX - notchRadius, 0, centerX - notchRadius, 5);

    // Create elegant semicircle notch
    path.arcToPoint(
      Offset(centerX + notchRadius, 5),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    // Smooth transition out of notch
    path.quadraticBezierTo(
      centerX + notchRadius,
      0,
      centerX + notchRadius + 5,
      0,
    );

    // Continue to right edge with rounded corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right side down with rounded corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom edge back to start
    path.lineTo(cornerRadius, size.height);

    path.close();

    // Draw background
    canvas.drawPath(path, backgroundPaint);

    // Draw subtle border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnhancedBottomBar extends StatelessWidget {
  const _EnhancedBottomBar({
    required this.selectedIndex,
    required this.onTap,
    required this.colorScheme,
    required this.animationController,
    required this.chatButtonController,
  });

  final int selectedIndex;
  final Function(int) onTap;
  final ColorScheme colorScheme;
  final AnimationController animationController;
  final AnimationController chatButtonController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Backdrop blur effect
            Container(
              height: 77, // Reduced height to fix overflow
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _EnhancedNotchPainter(
                  backgroundColor: backgroundColor,
                  borderColor: colorScheme.outline.withValues(alpha: 0.1),
                  isDark: isDark,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    02,
                  ), // Reduced padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _EnhancedNavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        selected: selectedIndex == 0,
                        onTap: () => onTap(0),
                        colorScheme: colorScheme,
                      ),
                      _EnhancedNavItem(
                        icon: Icons.insights_rounded,
                        label: 'Insights',
                        selected: selectedIndex == 1,
                        onTap: () => onTap(1),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 72), // Space for the chat button
                      _EnhancedNavItem(
                        icon: Icons.edit_note_rounded,
                        label: 'Journal',
                        selected: selectedIndex == 3,
                        onTap: () => onTap(3),
                        colorScheme: colorScheme,
                      ),
                      _EnhancedNavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        selected: selectedIndex == 4,
                        onTap: () => onTap(4),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Enhanced chat button positioned above the bar
            Positioned(
              top: -25,
              left: constraints.maxWidth / 2 - 36,
              child: _EnhancedChatButton(
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
                colorScheme: colorScheme,
                animationController: chatButtonController,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EnhancedNavItem extends StatefulWidget {
  const _EnhancedNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  State<_EnhancedNavItem> createState() => _EnhancedNavItemState();
}

class _EnhancedNavItemState extends State<_EnhancedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.selected
        ? widget.colorScheme.primary
        : widget.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final labelColor = widget.selected
        ? widget.colorScheme.primary
        : widget.colorScheme.onSurfaceVariant.withValues(alpha: 0.8);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with selection indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Selection background
                        if (widget.selected)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: widget.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        // Icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: widget.selected ? 1 : 0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, value, child) {
                            return Icon(
                              widget.icon,
                              color: primaryColor,
                              size: 22 + (value * 2),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Label with smooth color transition
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        color: labelColor,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
