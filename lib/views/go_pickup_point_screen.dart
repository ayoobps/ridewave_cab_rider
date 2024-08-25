import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class GoPickupPointScreen extends StatefulWidget {
  @override
  _GoPickupPointScreenState createState() => _GoPickupPointScreenState();
}

class _GoPickupPointScreenState extends State<GoPickupPointScreen> {
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
              "Go Pickup Point",
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
                "GO PICKUP POINT",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
            // SizedBox(height: 30),
            // IconButton(
            //     onPressed: () {
            //       Get.offNamedUntil('/reachpickuppoint',
            //           (Route<dynamic> route) => route.isFirst);
            //     },
            //     icon: Icon(
            //       Icons.refresh,
            //       color: Colors.green,
            //       size: 40,
            //     )),
            SizedBox(height: 10.h),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.green[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TRIP ID",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "#0000 0015",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),
                  Text(
                    "PICKUP LOCATION",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "G6G6+PCG, Naikkanal, Thrissur, Kerala, India",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.navigation, color: Colors.green),
                    ],
                  ),
                  Divider(),
                  Text(
                    "Customer Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Areefa Sali",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      Icon(Icons.phone, color: Colors.green),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Puzhangara Illath Palace, S.N.Nagar, Vadookara.P.O, Thrissur",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      //Icon(Icons.navigation, color: Colors.green),
                    ],
                  ),
                  Divider(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offNamedUntil('/reachpickuppoint',
                                (Route<dynamic> route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                      ),
                      child: Text(
                        "REACH PICKUP POINT",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "PAYMENT TYPE : ONLINE",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "₹104.06",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Trip Earning - ₹66.10\nTip - ₹0.00\nSurge - ₹14.00",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Distance - 2.6 km",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
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
