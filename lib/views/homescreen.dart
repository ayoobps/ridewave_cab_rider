import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;
  String userName = "Loading...";
  double cashCollectedAmount = 104.06;
  AudioPlayer audioPlayer = AudioPlayer();
  Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  LatLng _initialPosition = LatLng(20.5937, 78.9629); // Default to India
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _getCurrentLocation();
    _scheduleTripAlert();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('driver_data')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'];
          });
        } else {
          setState(() {
            userName = "User";
          });
        }
      }
    } catch (e) {
      setState(() {
        userName = "User";
      });
      Get.snackbar('Error', 'Failed to fetch user data.');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
      _initialPosition = LatLng(position.latitude, position.longitude);
    });

    GoogleMapController mapController = await _mapController.future;
    mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition));
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      _getCurrentLocation();
    });
  }

  void _scheduleTripAlert() {
    Future.delayed(Duration(seconds: 10), () {
      if (isOnline) {
        // Check if the user is online
        _playAlertSound();
        _showNewTripAlertDialog();
      }
    });
  }


  void _playAlertSound() async {
    try {
      print("Attempting to play sound...");
      await audioPlayer.setVolume(1.0);
      await audioPlayer.play(AssetSource('sounds/alert.mp3'));
      print("Sound played successfully.");
    } catch (e) {
      print("Error playing sound: $e");
      Get.snackbar('Error', 'Failed to play alert sound.');
    }
  }

  void _showNewTripAlertDialog() {
    Get.defaultDialog(
      title: "New Trip Alert",
      titleStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      content: Column(
        children: [
          Icon(
            Icons.directions_car,
            color: Colors.green,
            size: 60.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            "You have a new trip request.",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Text(
            "\u{20B9}${cashCollectedAmount}",
            style: TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold, fontSize: 35),
          ),
        ],
      ),
      onConfirm: () {
        Get.offNamed('/newtripalert');
      },
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      buttonColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[50],
        elevation: 0,
        title: Row(
          children: [
            Text(
              userName.toUpperCase(),
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
                setState(() {
                  isOnline = value;
                });
              },
              activeColor: Colors.green,
              inactiveTrackColor: Colors.red[100],
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 19.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),
          if (isOnline) // Show Lottie animation only if the user is online
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                width: double.infinity,
                height: 100.h,
                child: Lottie.asset('assets/lotties/lottie2.json'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[50],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Get.toNamed('/homescreen'),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Get.toNamed('/triphistory'),
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Get.toNamed('/settings'),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
