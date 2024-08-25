import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[50],
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Settings",
              style:
              TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              isOnline ? "Online" : "Offline", // Use ternary operator
              style: TextStyle(color: Colors.black45),
            ),
            Switch(
              value: isOnline,
              onChanged: (value) {
                setState(() {
                  isOnline = value;
                });
              },
              activeColor: Colors.green,
              inactiveTrackColor: Colors.red[100],
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[50],
        currentIndex: 2,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Get.toNamed('/homescreen'),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Get.toNamed('/triphistory'),
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Get.toNamed('/settings'),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
