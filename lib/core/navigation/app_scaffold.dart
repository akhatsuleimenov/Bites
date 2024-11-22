// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/screens/analytics/screens/analytics_screen.dart';
import 'package:bites/screens/dashboard/screens/dashboard_screen.dart';
import 'package:bites/screens/profile/screens/profile_screen.dart';

class AppScaffold extends StatefulWidget {
  final int initialIndex;

  const AppScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardScreen(),
          AnalyticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      // floatingActionButton: _selectedIndex == 0
      //     ? FloatingActionButton(
      //         heroTag: 'appScaffoldFAB',
      //         onPressed: () => Navigator.pushNamed(context, '/add-log'),
      //         child: const Icon(Icons.add_a_photo),
      //       )
      //     : null,
    );
  }
}
