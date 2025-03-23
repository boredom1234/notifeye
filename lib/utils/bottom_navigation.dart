import 'package:flutter/material.dart';
import 'package:crime/utils/theme.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int defaultSelectedIndex;

  const CustomBottomNavigationBar({required this.defaultSelectedIndex});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  final List<IconData> iconList = [
    Icons.notifications_active_outlined,
    Icons.report_outlined,
    Icons.home_outlined,
    Icons.forum_outlined,
    Icons.person_outline,
  ];

  final List<IconData> selectedIconList = [
    Icons.notifications_active,
    Icons.report,
    Icons.home,
    Icons.forum,
    Icons.person,
  ];

  final List<String> textList = [
    'Crime Alert',
    'Report',
    'Home',
    'Posts',
    'Account'
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              iconList.length,
              (index) => buildNavBarItem(
                selectedIcon: selectedIconList[index],
                unselectedIcon: iconList[index],
                index: index,
                label: textList[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavBarItem({
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required int index,
    required String label,
  }) {
    final isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => navigateBottom(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width / iconList.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: (isSelected ? AppTheme.bodySmall : AppTheme.bodySmall)
                  .copyWith(
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateBottom(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    String route;
    switch (index) {
      case 0:
        route = "/crimeAlert";
        break;
      case 1:
        route = "/crimeReport";
        break;
      case 2:
        route = "/home";
        break;
      case 3:
        route = "/postFeed";
        break;
      case 4:
        route = "/account";
        break;
      default:
        route = "/home";
    }

    Navigator.of(context).pushReplacementNamed(route);
  }
}


//TODO first navigation screen
//TODO user scenario 2-3
//TODO benefits for user and other party