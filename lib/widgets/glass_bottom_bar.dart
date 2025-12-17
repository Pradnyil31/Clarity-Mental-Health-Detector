import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassBottomBar extends StatefulWidget {
  const GlassBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  final int selectedIndex;
  final Function(int) onTap;
  final List<GlassBottomBarItem> items;

  @override
  State<GlassBottomBar> createState() => _GlassBottomBarState();
}

class _GlassBottomBarState extends State<GlassBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  int? _rippleIndex;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    );

    // Animate in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (widget.selectedIndex != index) {
      HapticFeedback.mediumImpact();
      setState(() => _rippleIndex = index);
      _rippleController.forward().then((_) {
        _rippleController.reset();
        setState(() => _rippleIndex = null);
      });
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _slideAnimation.value)),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            height: 75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.1,
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = widget.selectedIndex == index;
                      final showRipple = _rippleIndex == index;

                      return _GlassNavItem(
                        icon: item.icon,
                        activeIcon: item.activeIcon,
                        label: item.label,
                        selected: isSelected,
                        showRipple: showRipple,
                        onTap: () => _handleTap(index),
                        colorScheme: colorScheme,
                        rippleController: _rippleController,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassNavItem extends StatefulWidget {
  const _GlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.selected,
    required this.showRipple,
    required this.onTap,
    required this.colorScheme,
    required this.rippleController,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool selected;
  final bool showRipple;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final AnimationController rippleController;

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _bounceController.forward(),
      onTapUp: (_) => _bounceController.reverse(),
      onTapCancel: () => _bounceController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  if (widget.showRipple)
                    AnimatedBuilder(
                      animation: widget.rippleController,
                      builder: (context, child) {
                        return Container(
                          width: 50 * widget.rippleController.value,
                          height: 50 * widget.rippleController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.colorScheme.primary.withValues(
                              alpha: 0.3 * (1 - widget.rippleController.value),
                            ),
                          ),
                        );
                      },
                    ),
                  // Selection background
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: widget.selected ? 1 : 0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.colorScheme.primary.withValues(
                            alpha: 0.2 * value,
                          ),
                          border: value > 0.5
                              ? Border.all(
                                  color: widget.colorScheme.primary.withValues(
                                    alpha: 0.4 * value,
                                  ),
                                  width: 2,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  // Icon and label
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with smooth transition
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: widget.selected ? 1 : 0),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1.0 + (value * 0.2),
                            child: Icon(
                              widget.selected && widget.activeIcon != null
                                  ? widget.activeIcon!
                                  : widget.icon,
                              color: Color.lerp(
                                widget.colorScheme.onSurfaceVariant,
                                widget.colorScheme.primary,
                                value,
                              ),
                              size: 24,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      // Label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: widget.selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: widget.selected
                              ? widget.colorScheme.primary
                              : widget.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                          letterSpacing: 0.3,
                        ),
                        child: Text(widget.label),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GlassBottomBarItem {
  const GlassBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}
