import 'package:flutter/material.dart';
import 'package:taxi_food_admin/crud/grossary/food_page4.dart';
import 'package:taxi_food_admin/crud/main/main_menu_page.dart';
import 'package:taxi_food_admin/crud/restouran/restouran_page.dart';

import 'food_vegetables/food_page3.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    var margin = 20.0;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(margin),
                  width: screen.height / 1.5,
                  height: 200,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainMenuPage()),
                      );
                    },
                    child: Card(
                      color: Colors.indigoAccent,
                      child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "CATEGORY",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodPage3()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(margin),
                    width: screen.height / 1.5,
                    height: 200,
                    child: Card(
                      color: Colors.indigoAccent,
                      child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "VEGETABLES VS FRUITS",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(margin),
                  width: screen.height / 1.5,
                  height: 200,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RestaurantPage()),
                      );
                    },
                    child: Card(
                      color: Colors.indigoAccent,
                      child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "RESTOURANTS",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodPage4()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(margin),
                    width: screen.height / 1.5,
                    height: 200,
                    child: Card(
                      color: Colors.indigoAccent,
                      child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_grocery_store_sharp,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "GROCERY",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
