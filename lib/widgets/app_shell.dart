import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.index, required this.onIndex, required this.child});
  final int index;
  final ValueChanged<int> onIndex;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: child),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Bible'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
        NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    ),
  );
}
