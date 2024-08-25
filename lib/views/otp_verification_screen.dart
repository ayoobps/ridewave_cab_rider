import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:ridewave_cab_rider/controllers/auth_controller.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;

  OtpVerificationScreen({required this.verificationId});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> with CodeAutoFill {
  final AuthController authController = Get.find<AuthController>();
  Timer? _timer;
  int _start = 60; // Initial countdown duration in seconds
  bool _isResendAvailable = false;

  @override
  void initState() {
    super.initState();
    listenForCode();  // Start listening for the OTP code
    _startTimer();    // Start the timer for OTP resend
  }

  @override
  void codeUpdated() {
    setState(() {
      authController.otpController.text = code ?? ''; // Update OTP field with received code
    });
    authController.verifyOtp(widget.verificationId); // Verify the OTP automatically
  }

  void _startTimer() {
    _isResendAvailable = false;
    _start = 60; // Reset the timer duration
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_start == 0) {
          _isResendAvailable = true;
          timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  void _resendOtp() {
    authController.resendOtp(); // Resend the OTP
    _startTimer(); // Restart the timer for the resend button
  }

  @override
  void dispose() {
    cancel(); // Stop listening for the code
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF009951),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Center(
                child: Text(
                  'COCO',
                  style: GoogleFonts.inter(
                    color: Color(0xFF009951),
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            const Text(
              "Mobile Verification",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            PinFieldAutoFill(
              controller: authController.otpController,
              codeLength: 6, // Assuming the OTP is 6 digits long
              cursor: Cursor(
                width: 2.0, // Define the cursor width
                height: 20.0, // Define the cursor height
                color: Colors.green, // Set the cursor color to green
                radius: Radius.circular(1.0), // Optionally, make the cursor rounded
              ),
              decoration: BoxLooseDecoration(
                strokeColorBuilder: FixedColorBuilder(Colors.white), // Border color for the boxes
                bgColorBuilder: FixedColorBuilder(Colors.white), // Background color for the boxes
                textStyle: GoogleFonts.poppins(
                  color: Colors.black, // Text color inside the OTP fields
                  fontSize: 20,
                ),
                radius: Radius.circular(10.0), // Rounded corners for the boxes
                gapSpace: 10.0, // Space between each box
              ),
              currentCode: authController.otpController.text,
              onCodeSubmitted: (code) {
                authController.verifyOtp(widget.verificationId);
              },
            ),
            const SizedBox(height: 20),
            Obx(() => authController.isLoading.value
                ? Lottie.asset(
              'assets/lotties/loading.json',
              width: 70.0,
              height: 70.0,
              fit: BoxFit.fill,
            )
                : ElevatedButton(
              onPressed: () {
                authController.verifyOtp(widget.verificationId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Verify Now",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
            )),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isResendAvailable ? _resendOtp : null,
              style: TextButton.styleFrom(
                foregroundColor: _isResendAvailable ? const Color(0xFFC5FF39) : Colors.white,
              ),
              child: Text(
                _isResendAvailable ? "Resend OTP" : "Resend OTP in $_start seconds",
                style: TextStyle(
                  color: _isResendAvailable ? Colors.white : Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
