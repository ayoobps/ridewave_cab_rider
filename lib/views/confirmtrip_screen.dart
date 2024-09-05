import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripConfirmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the passed trip data
    final Map<String, dynamic> tripData = Get.arguments;

    String tripId = tripData['trip_id'];
    String pickupPlace = tripData['pickup_place'] ?? 'Unknown pickup location';
    String dropPlace = tripData['drop_place'] ?? 'Unknown drop location';
    String driverId = tripData['driver_id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pickup Location: $pickupPlace"),
            SizedBox(height: 10),
            Text("Drop Location: $dropPlace"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _confirmTripAndUpdateStatus(tripId, driverId, tripData);
              },
              child: Text('Confirm Trip'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to confirm the trip and update Firestore
  Future<void> _confirmTripAndUpdateStatus(
      String tripId, String driverId, Map<String, dynamic> tripData) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Save the trip details to the 'confirmed-trip' collection
      await firestore.collection('confirmed-trip').doc(tripId).set({
        'trip_id': tripId,
        'pickup_place': tripData['pickup_place'],
        'drop_place': tripData['drop_place'],
        'driver_id': driverId,
        'confirmed_at': Timestamp.now(),
        // Add any other relevant trip details here
      });

      // Update the 'trip_status' in the 'trip-request' collection to 'trip_accepted'
      await firestore.collection('trip-request').doc(tripId).update({
        'trip_status': 'trip_accepted',
        'accepted_at': Timestamp.now(), // Record the time when the trip was accepted
      });

      // Navigate to the DetailPage with the confirmed trip data
      Get.offNamed('/detailpage', arguments: tripData);

    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm the trip: $e');
    }
  }
}