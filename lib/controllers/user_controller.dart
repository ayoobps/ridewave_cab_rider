import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save user data to Firestore after successful registration
  Future<void> saveUserData(String firstName, String lastName, String email) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;
        String phoneNumber = user.phoneNumber ?? ''; // Get phone number from FirebaseAuth

        // Combine first name and last name
        String fullName = "$firstName $lastName";

        // Create a document in the user_data collection with the user's details
        await _firestore.collection('driver_data').doc(uid).set({
          'name': fullName,
          'email': email,
          'phone': phoneNumber,
        });

        Get.offNamed('/homescreen'); // Navigate to home screen after successful registration
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save user data: $e');
    }
  }
}