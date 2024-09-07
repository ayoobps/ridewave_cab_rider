import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTripAlertScreen extends StatefulWidget {
  @override
  _NewTripAlertScreenState createState() => _NewTripAlertScreenState();
}

final Map<String, dynamic> tripData = Get.arguments;

String tripId = tripData['trip_id'];
String pickupPlace = tripData['pickup_place'] ?? 'Unknown pickup location';
String dropPlace = tripData['drop_place'] ?? 'Unknown drop location';
String driverId = tripData['driver_id'];
String tripCode = tripData['trip_code'];
//double totalFare = tripData['fare'];
//double distanceKm = tripData['distance'];

// Get the passed trip data


class _NewTripAlertScreenState extends State<NewTripAlertScreen> {
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

  // Function to confirm the trip and update Firestore
  Future<void> _confirmTripAndUpdateStatus(
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
        //'fare' : totalFare,
        //'distance' : distanceKm,
        'confirmed_at': Timestamp.now(),
      });

      // Update the 'trip_status' in the 'trip-request' collection to 'accepted'
      await firestore.collection('trip-request').doc(tripId).update({
        'trip_status': 'accepted',
        'accepted_at': Timestamp.now(),
      });

      // Show a snackbar to notify the user of the successful update
      Get.snackbar('Success', 'Trip has been accepted successfully!',
          backgroundColor: Colors.green[100], colorText: Colors.green);

      // Navigate to the GoPickupPoint screen after accepting the trip
      Get.offNamedUntil(
          '/gopickuppoint', (Route<dynamic> route) => route.isFirst);
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm the trip: $e',
          backgroundColor: Colors.red[100], colorText: Colors.red);
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
                "New Trip Alert",
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
                  SizedBox(height: 20.h),
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
                          ],
                        ),
                        Divider(),
                        Text(
                          "Drop Location",
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
                                      'Are you sure you want to accept this trip?',
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
                                        onPressed: () async {
                                          await _confirmTripAndUpdateStatus(tripId, driverId, tripData);
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 12),
                            ),
                            child: Text(
                              "ACCEPT TRIP",
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Are you sure you want to transfer this trip?',
                                      style: TextStyle(
                                        color: Colors.red,
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
                                              '/homescreen',
                                                  (Route<dynamic> route) =>
                                              route.isFirst);
                                        },
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.red),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 12),
                            ),
                            child: Text(
                              "TRANSFER TRIP",
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            isPaymentOnline
                                ? "PAYMENT TYPE : ONLINE"
                                : "PAYMENT TYPE : CASH",
                            style: TextStyle(
                              color:
                              isPaymentOnline ? Colors.green : Colors.red,
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
                            style:
                            TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Distance - 2.6 km",
                            style:
                            TextStyle(color: Colors.black54, fontSize: 16),
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