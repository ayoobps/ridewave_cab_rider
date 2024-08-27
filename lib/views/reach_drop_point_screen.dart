import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReachDropPointScreen extends StatefulWidget {
  @override
  _ReachDropPointScreenState createState() => _ReachDropPointScreenState();
}

class _ReachDropPointScreenState extends State<ReachDropPointScreen> {
  bool isOnline = true;
  bool isCashCollected = false; // Track if cash is collected
  bool isPaymentOnline = false; // Track if the payment is online
  double cashCollectedAmount = 104.06; // Track the amount of cash collected

  @override
  void initState() {
    super.initState();
    // Initialize payment status based on initial cashCollectedAmount
    _updatePaymentStatus();
  }

  void _updatePaymentStatus() {
    setState(() {
      isPaymentOnline = cashCollectedAmount == 0;
    });
  }

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
                    "REACH DROP POINT",
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
                        "DROP LOCATION",
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
                          onPressed: isCashCollected
                              ? null // Disable button if cash is already collected
                              : () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Have you collected the cash?',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        Center(
                                          child: Text(
                                            '\u{20B9}${cashCollectedAmount}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                        setState(() {
                                          isCashCollected = true;
                                          cashCollectedAmount; // Set amount to zero after collection
                                          _updatePaymentStatus(); // Update payment status
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                          ),
                          child: Text(
                            "COLLECT CASH : \u{20B9}${cashCollectedAmount}",
                            style: TextStyle(color: Colors.white, fontSize: 20),
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
                      Divider(),
                      Center(
                        child: ElevatedButton(
                          onPressed: isCashCollected
                              ? () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Are you sure you want to complete this trip?',
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
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.offNamedUntil(
                                            '/tripcompleted',
                                                (Route<dynamic> route) => route.isFirst);
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                              : null, // Enable only if cash is collected
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCashCollected ? Colors.green : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                          ),
                          child: Text(
                            "COMPLETE TRIP",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "\u{20B9}${cashCollectedAmount}",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
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
    );
  }
}
