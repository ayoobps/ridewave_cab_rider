import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTripController extends GetxController {
  final RxBool isOnline = true.obs;
  final RxBool isCashCollected = false.obs;
  final RxBool isPaymentOnline = false.obs;
  final RxDouble cashCollectedAmount = 104.06.obs;
  final RxString tripId = "".obs;
  final RxString pickupLocation = "".obs;
  final RxString customerName = "".obs;
  final RxString customerPhone = "".obs;
  final RxString customerAddress = "".obs;
  final RxDouble distance = 2.6.obs;
  final RxString paymentType = "".obs;
  final RxString earnings = "₹66.10".obs;
  final RxString tip = "₹0.00".obs;
  final RxString surge = "₹14.00".obs;

  // Initialize with some trip data
  void initTripData(String tripId) async {
    this.tripId.value = tripId;
    // Fetch trip data from Firestore and set variables
    DocumentSnapshot tripDoc = await FirebaseFirestore.instance
        .collection('trips-from-user')
        .doc(tripId)
        .get();

    if (tripDoc.exists) {
      pickupLocation.value = tripDoc['pickup_place'] ?? "No Location";
      customerName.value = tripDoc['name'] ?? "No Name";
      customerPhone.value = tripDoc['phone'] ?? "No Phone";
      customerAddress.value = tripDoc['drop_place'] ?? "No Address"; // Assuming drop_place as address
      distance.value = tripDoc['distance'] ?? 2.6; // You might need to calculate distance if it's not in your data
      paymentType.value = tripDoc['payment_type'] ?? "CASH"; // Assuming 'payment_type' exists or needs to be managed
      earnings.value = tripDoc['earnings'] ?? "₹66.10"; // Add logic to calculate earnings if needed
      tip.value = tripDoc['tip'] ?? "₹0.00";
      surge.value = tripDoc['surge'] ?? "₹14.00";
    }
  }

  void acceptTrip() async {
    try {
      // Fetch trip data
      DocumentSnapshot tripDoc = await FirebaseFirestore.instance
          .collection('trips-from-user')
          .doc(tripId.value)
          .get();

      if (tripDoc.exists) {
        // Ensure the data is of type Map<String, dynamic>
        Map<String, dynamic>? tripData = tripDoc.data() as Map<String, dynamic>?;

        if (tripData != null) {
          // Add trip data to 'trips-driver-accepted'
          await FirebaseFirestore.instance
              .collection('trips-driver-accepted')
              .doc(tripId.value)
              .set(tripData);

          // Remove trip from 'trips-from-user'
          await FirebaseFirestore.instance
              .collection('trips-from-user')
              .doc(tripId.value)
              .delete();

          // Navigate to the next screen
          Get.offNamedUntil('/gopickuppoint', (Route<dynamic> route) => route.isFirst);
        } else {
          Get.snackbar('Error', 'Trip data is null or in incorrect format.');
        }
      } else {
        Get.snackbar('Error', 'Trip not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept the trip. Error: $e');
    }
  }

  void transferTrip() async {
    try {
      await FirebaseFirestore.instance
          .collection('trips-from-user')
          .doc(tripId.value)
          .delete();

      Get.offNamedUntil('/homescreen', (Route<dynamic> route) => route.isFirst);
    } catch (e) {
      Get.snackbar('Error', 'Failed to transfer the trip.');
    }
  }
}
