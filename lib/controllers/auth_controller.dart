import 'dart:developer';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ridewave_cab_rider/views/otp_verification_screen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String? _verificationId;
  int? _forceResendingToken;

  // Function to validate the phone number format
  bool validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phoneNumber);
  }

  // Function to verify the phone number and send the OTP
  Future<void> verifyPhoneNumber(BuildContext context) async {
    String phoneNumber = '+91' + phoneController.text.trim();

    if (validatePhoneNumber(phoneNumber)) {
      isLoading(true);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 120), // Extended timeout
        verificationCompleted: (phoneAuthCredential) {
          // Automatically verify the user if auto-retrieval succeeds
          FirebaseAuth.instance.signInWithCredential(phoneAuthCredential).then((userCredential) {
            // Navigate to the desired screen
            Get.offAllNamed('/homescreen');
          }).catchError((error) {
            log(error.toString());
            Get.snackbar('Auto verification failed', 'Please enter the OTP manually.');
          });
        },
        verificationFailed: (error) {
          log(error.toString());
          isLoading(false);
          Get.snackbar('Verification failed', error.message ?? 'Error');
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
          _forceResendingToken = forceResendingToken;
          isLoading(false);
          Get.to(() => OtpVerificationScreen(verificationId: verificationId));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          log("Auto Retrieval timeout");
          Get.snackbar('Auto Retrieval timeout', 'Please enter the OTP manually.');
        },
      );

    } else {
      Get.snackbar(
        'Invalid phone number format',
        'Please enter in E.164 format.',
      );
    }
  }

  // Function to verify OTP
  Future<void> verifyOtp(String verificationId) async {
    isLoading(true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(cred);
      String userId = userCredential.user?.uid ?? '';

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('driver_data')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // User exists, navigate to HomeScreen
        Get.offAllNamed('/homescreen');
      } else {
        // User does not exist, navigate to Register screen
        Get.offAllNamed('/register');
      }
    } catch (e) {
      log(e.toString());
      Get.snackbar('OTP verification failed', 'Please try again.');
    } finally {
      isLoading(false);
    }
  }

  // Function to resend OTP
  Future<void> resendOtp() async {
    String phoneNumber = '+91' + phoneController.text.trim();

    if (_forceResendingToken != null) {
      isLoading(true);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (error) {
          log(error.toString());
          isLoading(false);
          Get.snackbar('Resend failed', error.message ?? 'Error');
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
          _forceResendingToken = forceResendingToken;
          isLoading(false);
          Get.snackbar('OTP Resent', 'A new OTP has been sent to your phone.');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          log("Auto Retrieval timeout");
        },
      );
    } else {
      Get.snackbar(
        'Resend not allowed',
        'Please wait before requesting a new OTP.',
      );
    }
  }
}