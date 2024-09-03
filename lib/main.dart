import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridewave_cab_rider/views/customer_data_page.dart';
import 'package:ridewave_cab_rider/views/go_drop_point_screen.dart';
import 'package:ridewave_cab_rider/views/go_pickup_point_screen.dart';
import 'package:ridewave_cab_rider/views/homescreen.dart';
import 'package:ridewave_cab_rider/views/login_screen.dart';
import 'package:ridewave_cab_rider/views/new_trip_alert_screen.dart';
import 'package:ridewave_cab_rider/views/otp_verification_screen.dart';
import 'package:ridewave_cab_rider/views/reach_drop_point_screen.dart';
import 'package:ridewave_cab_rider/views/reach_pickup_point_screen.dart';
import 'package:ridewave_cab_rider/views/register.dart';
import 'package:ridewave_cab_rider/views/settings_screen.dart';
import 'package:ridewave_cab_rider/views/splash_screen.dart';
import 'package:ridewave_cab_rider/views/trip_completed_screen.dart';
import 'package:ridewave_cab_rider/views/trip_history_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Example dependency injection
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set design size based on your design
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ride Wave Driver',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        getPages: [
          //GetPage(name: '/', page: () => SplashScreen()),
          //GetPage(name: '/phone', page: () => LoginScreen()),
          //GetPage(name: '/', page: () => OtpVerificationScreen(verificationId: '')),
          //GetPage(name: '/register', page: () => Register()),
          GetPage(name: '/', page: () => HomeScreen()),
          GetPage(name: '/newtripalert', page: () => NewTripAlertScreen()),
          GetPage(name: '/gopickuppoint', page: () => GoPickupPointScreen()),
          GetPage(name: '/reachpickuppoint', page: () => ReachPickupPointScreen()),
          GetPage(name: '/godroppoint', page: () => GoDropPointScreen()),
          GetPage(name: '/reachdroppoint', page: () => ReachDropPointScreen()),
          GetPage(name: '/tripcompleted', page: () => TripCompletedScreen()),
          GetPage(name: '/triphistory', page: () => TripHistoryScreen()),
          GetPage(name: '/settings', page: () => SettingsScreen()),
          //GetPage(name: '/settings', page: () => CustomerDataPage()),
        ],
      ),
    );
  }
}
