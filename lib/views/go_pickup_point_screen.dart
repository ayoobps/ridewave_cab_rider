import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GoPickupPointScreen extends StatefulWidget {
  @override
  _GoPickupPointScreenState createState() => _GoPickupPointScreenState();
}

class _GoPickupPointScreenState extends State<GoPickupPointScreen> {
  bool isOnline = true;
  bool isCashCollected = false;
  bool isPaymentOnline = false;
  double cashCollectedAmount = 104.06;

  void _updatePaymentStatus() {
    setState(() {
      isPaymentOnline = cashCollectedAmount == 0;
    });
  }

  void _toggleOnlineStatus(bool value) {
    if (!value) {
      // If the user tries to switch to offline, prevent the switch
      Get.snackbar('Warning', 'Current trip must be completed to go offline.',
          backgroundColor: Colors.red[100], colorText: Colors.red);
      return; // Do nothing, the switch won't change
    } else {
      setState(() {
        isOnline = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green[50],
          elevation: 0,
          title: Row(
            children: [
              Text(
                "Go Pickup Point",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                isOnline ? "Online" : "Offline",
                style: TextStyle(color: Colors.black45),
              ),
              Switch(
                value: isOnline,
                onChanged: (value) {
                  _toggleOnlineStatus(value);
                },
                activeColor: Colors.green,
                inactiveTrackColor: Colors.red[100],
                inactiveThumbColor: Colors.red,
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.green),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "GO PICKUP POINT",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
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
                          "CUSTOMER DETAILS",
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
                          ],
                        ),
                        Divider(),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'You have reached the pickup location?',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                      ),
                                    ),
                                    backgroundColor: Colors.green[50],
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "No",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.offNamedUntil(
                                            '/reachpickuppoint',
                                                (Route<dynamic> route) => route.isFirst,
                                          );
                                        },
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 12),
                            ),
                            child: Text(
                              "REACH PICKUP POINT",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            isPaymentOnline ? "PAYMENT TYPE : ONLINE" : "PAYMENT TYPE : CASH",
                            style: TextStyle(
                              color: isPaymentOnline ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "\u{20B9}${cashCollectedAmount}",
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
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green[50],
          currentIndex: 0,
          selectedItemColor: Colors.black54,
          unselectedItemColor: Colors.black54,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
