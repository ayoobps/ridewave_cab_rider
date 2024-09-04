import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripConfirmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the passed trip data
    final Map<String, dynamic> tripData = Get.arguments;

    String tripId = tripData['trip_id']; // Assuming you have the trip ID
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
                await _confirmTripAndDeleteRequest(tripId, tripData, driverId);
              },
              child: Text('Confirm Trip'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _confirmTripAndDeleteRequest(
      String tripId, Map<String, dynamic> tripData, String driverId) async {
    try {
      // Reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if the document exists in the trips-from-user collection
      DocumentSnapshot tripDoc = await firestore.collection('trips-from-user').doc(tripId).get();

      if (tripDoc.exists) {
        // If the document exists, proceed with the confirmation and deletion

        // Save the trip details to 'confirmed-trips' collection
        await firestore.collection('confirmed-trips').doc(tripId).set({
          'trip_id': tripId,
          'pickup_place': tripData['pickup_place'],
          'drop_place': tripData['drop_place'],
          'driver_id': driverId,
          'confirmed_at': Timestamp.now(),
          'trip-status': 'confirmed', // Add trip status field
        });

        // Update the "trip-status" to "confirmed" in 'trips-from-user' collection
        await firestore.collection('trips-from-user').doc(tripId).update({
          'trip-status': 'confirmed', // Update trip status to confirmed
        });

        // Log the tripId for debugging purposes
        print('Trip ID: $tripId');

        // Show a success message and navigate back to the home screen or another screen
        Get.snackbar('Success', 'Trip confirmed and requests deleted.');
        Get.offAllNamed('/homescreen'); // Navigate to the home screen or other page
      } else {
        // If the document doesn't exist, show an error
        Get.snackbar('Error', 'Trip request not found.');
      }
    } catch (e) {
      // Handle any errors
      print("Error during trip confirmation: $e");
      Get.snackbar('Error', 'Failed to confirm the trip: $e');
    }
  }
}