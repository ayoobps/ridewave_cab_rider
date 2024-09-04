import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isOnline = true;
  bool isCashCollected = false; // Track if cash is collected
  bool isPaymentOnline = false; // Track if the payment is online
  double cashCollectedAmount = 104.06; // Track the amount of cash collected

  String name = "Loading...";
  String email = "Loading...";
  String phone = "Loading...";
  String status = "Loading...";
  GeoPoint? currentLocation;
  Timestamp? lastUpdated;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updatePaymentStatus();
    _fetchUserData();
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

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('driver_data')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc['name'] ?? "No Name";
            email = userDoc['email'] ?? "No Email";
            phone = userDoc['phone'] ?? "No Phone";
            status = userDoc['status'] ?? "No Status";
            currentLocation = userDoc['current_location'] as GeoPoint?;
            lastUpdated = userDoc['last_updated'] as Timestamp?;

            _nameController.text = name;
            _emailController.text = email;
            _phoneController.text = phone; // Display phone but don't edit
          });
        } else {
          // Handle case where user document does not exist
          setState(() {
            name = "No Name";
            email = "No Email";
            phone = "No Phone";
            status = "No Status";
          });
        }
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
      Get.snackbar(
        'Error',
        'Failed to fetch user data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updateProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('driver_data')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'last_updated': Timestamp.now(), // Update the timestamp
        });

        Get.snackbar('Success', 'Profile updated successfully.');
      }
    } catch (e) {
      print("Failed to update profile: $e");
      Get.snackbar(
        'Error',
        'Failed to update profile.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Name:",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Email:",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Phone:",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Phone number',
              ),
              enabled: false, // Make the phone number field non-editable
            ),
            SizedBox(height: 10.h),
            Text(
              "Status: $status",
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              "Location: ${currentLocation != null ? '${currentLocation!.latitude}, ${currentLocation!.longitude}' : 'No Location'}",
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              "Last Updated: ${lastUpdated != null ? lastUpdated!.toDate().toLocal().toString() : 'Never'}",
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Update Profile",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
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
