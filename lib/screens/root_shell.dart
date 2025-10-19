import 'package:flutter/material.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.bodyBuilder});
  final WidgetBuilder bodyBuilder;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _go(int i) {
    setState(() => _index = i);
    switch (i) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/insights');
        break;
      case 2:
        // reserved for center chat FAB
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: widget.bodyBuilder(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 76,
        width: 76,
        child: FloatingActionButton(
          tooltip: 'Open chat',
          elevation: 4,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).pushNamed('/chat'),
          child: const Icon(Icons.chat_bubble_rounded, size: 30),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: const CircularNotchedRectangle(),
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: _index == 0,
              onTap: () => _go(0),
            ),
            _NavItem(
              icon: Icons.insights_rounded,
              label: 'Insights',
              selected: _index == 1,
              onTap: () => _go(1),
            ),
            const SizedBox(width: 56), // space for FAB notch
            _NavItem(
              icon: Icons.edit_note_rounded,
              label: 'Journal',
              selected: _index == 3,
              onTap: () => _go(3),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: _index == 4,
              onTap: () => _go(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final weight = selected ? FontWeight.w600 : FontWeight.w400;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: weight),
            ),
          ],
        ),
      ),
    );
  }
}
