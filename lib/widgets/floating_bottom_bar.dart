import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingBottomBar extends StatefulWidget {
  const FloatingBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  final int selectedIndex;
  final Function(int) onTap;
  final List<FloatingBottomBarItem> items;

  @override
  State<FloatingBottomBar> createState() => _FloatingBottomBarState();
}

class _FloatingBottomBarState extends State<FloatingBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    // Animate in on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (widget.selectedIndex != index) {
      HapticFeedback.lightImpact();
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = widget.selectedIndex == index;

            return _FloatingNavItem(
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              selected: isSelected,
              onTap: () => _handleTap(index),
              colorScheme: colorScheme,
              animationController: _animationController,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatefulWidget {
  const _FloatingNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.animationController,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final AnimationController animationController;

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverController,
            widget.animationController,
          ]),
          builder: (context, child) {
            final scale =
                _scaleAnimation.value *
                (1.0 - widget.animationController.value * 0.1);

            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.selected ? 20 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? widget.colorScheme.primary.withValues(alpha: 0.15)
                      : _isHovered
                      ? widget.colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: widget.selected
                      ? Border.all(
                          color: widget.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with smooth transition
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: widget.selected ? 1 : 0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Icon(
                          widget.selected && widget.activeIcon != null
                              ? widget.activeIcon!
                              : widget.icon,
                          color: Color.lerp(
                            widget.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            widget.colorScheme.primary,
                            value,
                          ),
                          size: 22 + (value * 2),
                        );
                      },
                    ),
                    // Label with slide animation
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: widget.selected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                widget.label,
                                style: TextStyle(
                                  color: widget.colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FloatingBottomBarItem {
  const FloatingBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}
