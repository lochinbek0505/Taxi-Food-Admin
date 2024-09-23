import 'package:flutter/material.dart';
import 'package:taxi_food_admin/crud/control.dart';
import 'package:taxi_food_admin/orders/receive.dart';
import 'package:taxi_food_admin/requerments.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _pages = [OrderScreen(), ControlPage(), Requerments()];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        NavigationRail(
          minWidth: 54,
          // extended: true,
          // useIndicator: false,
          groupAlignment: 0.1,
          indicatorColor: Color(0xff2A5270),
          labelType: NavigationRailLabelType.all,
          selectedLabelTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            // _selectedIndex = index;
          },
          unselectedLabelTextStyle:
              TextStyle(color: Colors.white70, fontSize: 13),
          destinations: [
            NavigationRailDestination(
              icon: SizedBox(),
              label: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'ORDERS',
                ),
              ),
            ),
            NavigationRailDestination(
                icon: SizedBox(),
                label: RotatedBox(
                  quarterTurns: -1,
                  child: Text("EDIT"),
                )),
            NavigationRailDestination(
              icon: SizedBox(),
              label: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'MAIN',
                ),
              ),
            ),
          ],
          selectedIndex: _selectedIndex,
          backgroundColor: Color(0xff2A5270),
        ),
        VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(
          child: Center(
            child: _pages[_selectedIndex],
          ),
        )
      ],
    ));
  }
}
