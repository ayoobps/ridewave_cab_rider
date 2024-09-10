
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'new_trip_alert_screen.dart';

class ReachPickupPointScreen extends StatefulWidget {
  @override
  _ReachPickupPointScreenState createState() => _ReachPickupPointScreenState();
}

class _ReachPickupPointScreenState extends State<ReachPickupPointScreen> {
  bool isOnline = true;
  bool isCashCollected = false; // Track if cash is collected
  bool isPaymentOnline = false; // Track if the payment is online


  // Function to confirm the trip and update Firestore
  Future<void> _confirmStartTripStatus(
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
        'trip_status': 'tripstarted',
        'accepted_at': Timestamp.now(),
      });

      // Show a snackbar to notify the user of the successful update
      Get.snackbar('Success', 'Your trip started!',
          backgroundColor: Colors.green[100], colorText: Colors.green);

      // Navigate to the Reach Pickup Point screen
      Get.offNamedUntil('/godroppoint', (Route<dynamic> route) => route.isFirst);
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm: $e',
          backgroundColor: Colors.red[100], colorText: Colors.red);
    }
  }



  // Open Google Maps for navigation
  void _openMap(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the map.';
    }
  }


  void _updatePaymentStatus() {
    setState(() {
      isPaymentOnline = totalFare == 0;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
       canPop: false,

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green[50],
          elevation: 0,
          title: Row(
            children: [
              Text(
                "Reach Pickup Point",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                      "REACH PICKUP POINT",
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TRIP ID",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
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
                            child: TextFormField(
                              controller: _otpController,
                              decoration: InputDecoration(
                                hintText: 'Enter PIN Here',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter PIN';
                                } else if (value.length != 4) {
                                  return 'PIN should be 4 digits';
                                } else if (value != tripPin) {
                                  return 'Incorrect PIN. Please try again.';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Are you ready to start the trip?',
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
                                              onPressed: () async{
                                                if (_formKey.currentState!.validate()) {
                                                  await _confirmStartTripStatus(tripId, driverId, tripData);
                                                  Get.offNamedUntil('/godroppoint',
                                                          (Route<dynamic> route) => route.isFirst);
                                                }
                                              },
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ))
                                        ],
                                      );
                                    });
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
                                "START TRIP",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Divider(),
                          Text(
                            "DROP LOCATION",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_pin, color: Colors.black54),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$dropPlace",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  _openMap(dropLat, dropLng);
                                },
                                child: Icon(Icons.navigation, color: Colors.green),
                              ),
                            ],
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
                              "\u{20B9} $totalFare",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Distance - $distanceKm KM",
                              style:
                                  TextStyle(color: Colors.black54, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
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
