import 'package:crime/account/components/color.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int defaultSelectedIndex;

  const CustomBottomNavigationBar({required this.defaultSelectedIndex});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  List<IconData> iconList = [];
  List<String> textList = [];

  @override
  initState() {
    super.initState();
    iconList = [
      Icons.map,
      Icons.local_police_rounded,
      Icons.home,
      Icons.post_add_rounded,
      Icons.person,
    ];
    textList = ['Crime Alert', 'Crime Report', 'Home', 'Posts', 'Account'];
    _selectedIndex = widget.defaultSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _navBarItemList = [];

    for (var i = 0; i < iconList.length; i++) {
      _navBarItemList.add(buildNavBarItem(iconList[i], i, textList[i]));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: _navBarItemList,
      ),
    );
  }

  Widget buildNavBarItem(IconData icon, int index, String label) {
    return GestureDetector(
      onTap: () {
        navigateBottom(index);
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / iconList.length,
        decoration: index == _selectedIndex
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 4, color: secondaryColor),
                ),
              )
            : const BoxDecoration(),
        child: Column(
          children: [
            Icon(
              icon,
              color: index == _selectedIndex ? secondaryColor : primaryColor,
            ),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: index == _selectedIndex
                      ? Colors.red.shade900
                      : Colors.grey,
                )),
          ],
        ),
      ),
    );
  }

  void navigateBottom(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/crimeAlert");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/crimeReport");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/home");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/postFeed");
        break;
      case 4:
        Navigator.pushReplacementNamed(context, "/account");
        break;
      case 5:
        break;
    }
  }
}


//TODO first navigation screen
//TODO user scenario 2-3
//TODO benefits for user and other party