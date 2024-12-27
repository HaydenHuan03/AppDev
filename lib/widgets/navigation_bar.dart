import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final int initialIndex;

  const CustomNavigationBar({
    super.key,
    this.initialIndex = 2  // Default to home index
  });

  @override
  State<CustomNavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<CustomNavigationBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _handleNavigation(BuildContext context, int index) {
    if (_selectedIndex == index) return; // Don't navigate if already on the page

    setState(() {
      _selectedIndex = index;
    });

    String route;
    bool shouldReplaceAll = false;

    switch (index) {
      case 0:
        route = '/booking';
        break;
      case 1:
        route = '/shopping';
        break;
      case 2:
        route = '/home';
        shouldReplaceAll = true;  // Clear stack when going home
        break;
      case 3:
        route = '/promotion';
        break;
      case 4:
        route = '/profile';
        break;
      default:
        debugPrint('Invalid navigation index: $index');
        return;
    }

    if (shouldReplaceAll) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (route) => false,  // Remove all previous routes
      );
    } else {
      Navigator.pushNamed(context, route).then((_) {
        // Reset to previous index when returning
        if (mounted) {
          setState(() {
            _selectedIndex = widget.initialIndex;
          });
        }
      });
    }
  }

  final List<NavigationIcon> _navigationIcons = [
    NavigationIcon(iconPath: 'assets/images/booking.png', label: 'Booking'),
    NavigationIcon(iconPath: 'assets/images/shopping.png', label: 'Shopping'),
    NavigationIcon(iconPath: 'assets/images/home.png', label: 'Home'),
    NavigationIcon(iconPath: 'assets/images/promotion.png', label: 'Promotion'),
    NavigationIcon(iconPath: 'assets/images/profile.png', label: 'Profile'),
  ];

  Widget _buildNavigationIcons(NavigationIcon icon, int index) {
    final isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                const SizedBox(
                  height: 24,
                  width: 24,
                ),
              Image.asset(
                icon.iconPath,
                height: 24,
                width: 24,
                color: !isSelected ? Colors.white : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            icon.label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(251, 38, 38, 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _navigationIcons
          .asMap()
          .entries
          .map((entry) => _buildNavigationIcons(entry.value, entry.key))
          .toList(),
      ),
    );
  }
}

class NavigationIcon {
  final String iconPath;
  final String label;

  NavigationIcon({
    required this.iconPath,
    required this.label,
  });
}