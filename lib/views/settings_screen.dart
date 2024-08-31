import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Sign out the user
                  await FirebaseAuth.instance.signOut();

                  // Navigate to the login screen or any other screen
                  Get.offAllNamed('/phone');
                } catch (e) {
                  // Handle errors (if any)
                  Get.snackbar(
                    'Logout Failed',
                    'An error occurred while logging out.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.red),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "LOGOUT",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[50],
        currentIndex: 2, // Set the current index to 2 for the Settings page
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
