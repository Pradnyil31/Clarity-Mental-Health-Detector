import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/floating_bottom_bar.dart';

class RootShellFloating extends StatefulWidget {
  const RootShellFloating({super.key, required this.bodyBuilder});
  final WidgetBuilder bodyBuilder;

  @override
  State<RootShellFloating> createState() => _RootShellFloatingState();
}

class _RootShellFloatingState extends State<RootShellFloating> {
  int _index = 0;

  void _go(int i) {
    if (_index != i) {
      HapticFeedback.lightImpact();
      setState(() => _index = i);

      switch (i) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/');
          break;
        case 1:
          Navigator.of(context).pushReplacementNamed('/insights');
          break;
        case 2:
          Navigator.of(context).pushNamed('/chat');
          break;
        case 3:
          Navigator.of(context).pushReplacementNamed('/journal');
          break;
        case 4:
          Navigator.of(context).pushReplacementNamed('/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.bodyBuilder(context),
      extendBody: true,
      bottomNavigationBar: FloatingBottomBar(
        selectedIndex: _index,
        onTap: _go,
        items: const [
          FloatingBottomBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          FloatingBottomBarItem(
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights_rounded,
            label: 'Insights',
          ),
          FloatingBottomBarItem(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'Chat',
          ),
          FloatingBottomBarItem(
            icon: Icons.edit_note_outlined,
            activeIcon: Icons.edit_note_rounded,
            label: 'Journal',
          ),
          FloatingBottomBarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
