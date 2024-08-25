import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:ridewave_cab_rider/controllers/auth_controller.dart';


class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF009951),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              TextFormField(
                cursorColor: Colors.green,
                controller: authController.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Mobile Number',
                  hintText: 'Mobile Number',
                  //labelText: 'Mobile Number',
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.black54,
                  ),
                  prefixText: '+91   ',

                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone field can't be empty";
                  }

                  final pattern = r'^[6-9]\d{9}$';
                  final regex = RegExp(pattern);

                  if (!regex.hasMatch(value)) {
                    return "Enter a valid 10-digit phone number starting with 6, 7, 8, or 9";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => authController.isLoading.value
                  ? Lottie.asset(
                'assets/lotties/loading.json', // Replace with the path to your Lottie file
                width: 70.0,
                height: 70.0,
                fit: BoxFit.fill,
              )
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authController.verifyPhoneNumber(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Login Now',
                  style: GoogleFonts.inter(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}