import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'new_trip_alert_screen.dart';

class GoPickupPointScreen extends StatefulWidget {
  @override
  _GoPickupPointScreenState createState() => _GoPickupPointScreenState();
}

class _GoPickupPointScreenState extends State<GoPickupPointScreen> {
  bool isOnline = true;
  bool isCashCollected = false;
  bool isPaymentOnline = false;
  String cashCollectedAmount = totalFare;

  // Open Google Maps for navigation
  void _openMap(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the map.';
    }
  }

  // Toggle the driver's online status
  void _toggleOnlineStatus(bool value) {
    if (!value) {
      // Prevent going offline during an active trip
      Get.snackbar('Warning', 'Current trip must be completed to go offline.',
          backgroundColor: Colors.red[100], colorText: Colors.red);
      return;
    } else {
      setState(() {
        isOnline = value;
      });
    }
  }

  // Function to confirm the trip and update Firestore
  Future<void> _confirmReachPickupStatus(
      String tripId, String driverId, Map<String, dynamic> tripData) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Save the trip details to the 'confirmed-trip' collection
      await firestore.collection('confirmed-trip').doc(tripId).set({
        'trip_id': tripId,
        'trip_code': tripCode,
        'pickup_place': tripData['pickup_place'],
        'drop_place': tripData['drop_place'],
        'driver_id': driverId,
        'fare': totalFare,
        'distance': distanceKm,
        'user_id': customerId,
        'confirmed_at': Timestamp.now(),
      });

      // Update the 'trip_status' in the 'trip-request' collection to 'reachpickup'
      await firestore.collection('trip-request').doc(tripId).update({
        'trip_status': 'reachpickup',
        'accepted_at': Timestamp.now(),
      });

      // Show a snackbar to notify the user of the successful update
      Get.snackbar('Success', 'You have reached the pickup point!',
          backgroundColor: Colors.green[100], colorText: Colors.green);

      // Navigate to the Reach Pickup Point screen
      Get.offNamedUntil('/reachpickuppoint', (Route<dynamic> route) => route.isFirst);
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm: $e',
          backgroundColor: Colors.red[100], colorText: Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
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
                    onPressed: () {
                      // Implement navigation to the pickup point using GPS if needed
                    },
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
                          "$tripCode",
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
                                "$pickupPlace",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _openMap(pickupLat, pickupLng);
                              },
                              child: Icon(Icons.navigation, color: Colors.green),
                            ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$userName",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    "$userEmail",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (userPhone != null) {
                                  launch("tel:$userPhone");
                                }
                              },
                              child: Icon(Icons.phone, color: Colors.green),
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
                                      'Have you reached the pickup location?',
                                      style: TextStyle(color: Colors.green, fontSize: 20),
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
                                        onPressed: () async {
                                          await _confirmReachPickupStatus(tripId, driverId, tripData);
                                          Get.offNamedUntil(
                                              '/reachpickuppoint', (Route<dynamic> route) => route.isFirst);
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
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
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
                            "\u{20B9}${cashCollectedAmount}",
                            style: TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Distance - $distanceKm KM",
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