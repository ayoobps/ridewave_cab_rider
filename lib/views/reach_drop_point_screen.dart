import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ReachDropPointScreen extends StatefulWidget {
  @override
  _ReachDropPointScreenState createState() => _ReachDropPointScreenState();
}

class _ReachDropPointScreenState extends State<ReachDropPointScreen> {
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
              "Reach Drop Point",
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
          children: [
            SizedBox(
              height: 10.h,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                // primary: Colors.white,
                // onPrimary: Colors.green,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "REACH DROP POINT",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 30),
            IconButton(
                onPressed: () {
                  Get.offNamedUntil('/tripcompleted',
                          (Route<dynamic> route) => route.isFirst);
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.green,
                  size: 40,
                )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[50],
        currentIndex: 0,
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            // icon: IconButton(
            icon: Icon(Icons.home),
            //   onPressed: () => Get.toNamed('/'),
            // ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            // icon: IconButton(
            icon: Icon(Icons.menu),
            //   onPressed: () => Get.toNamed('/triphistory'),
            // ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            // icon: IconButton(
            icon: Icon(Icons.settings),
            //   onPressed: () => Get.toNamed('/settings'),
            // ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
