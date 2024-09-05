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
  AudioPlayer audioPlayer = AudioPlayer();
  Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  LatLng? _initialPosition;
  Timer? _locationUpdateTimer;
  Timer? _autoRefreshTimer;
  bool isManualRefreshCooldown = false;
  Timer? _locationCooldownTimer;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _getCurrentLocation();
    _startLocationUpdates();
    _listenToTripRequests(); // Listen for trip requests with status "driver_assigned"
    _updateDriverStatus();
    if (isOnline) {
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _locationCooldownTimer?.cancel();
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
    if (!isOnline) return;

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
    mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition!));

    _updateLocationInFirebase(position);
    _startLocationCooldown();
  }

  Future<void> _updateLocationInFirebase(Position position) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('driver_data')
            .doc(user.uid)
            .update({
          'current_location': GeoPoint(position.latitude, position.longitude),
          'last_updated': Timestamp.now(),
          'status': isOnline ? 'online' : 'offline',
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update location.');
    }
  }

  void _listenToTripRequests() {
    FirebaseFirestore.instance
        .collection('trip-request')
        .where('driver_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('trip_status', isEqualTo: 'driver_assigned')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        var tripData = change.doc.data() as Map<String, dynamic>?;

        // Ensure the driver is online before proceeding with the trip alert
        if (isOnline && tripData != null) {
          // Check if the trip status is 'driver_assigned'
          if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
            _playAlertSound();
            _showTripData(tripData);
          }
        }
      }
    });
  }
  void _showTripData(Map<String, dynamic> tripData) {
    String pickupPlace = tripData['pickup_place'] ?? 'Unknown pickup location';
    String dropPlace = tripData['drop_place'] ?? 'Unknown drop location';

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
            "Pickup: $pickupPlace",
            style: TextStyle(fontSize: 16.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Text(
            "Drop: $dropPlace",
            style: TextStyle(fontSize: 16.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      onConfirm: () {
        audioPlayer.stop();
        Get.offNamed('/tripconfirm', arguments: tripData); // Navigate to confirmation screen
      },
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      buttonColor: Colors.green,
    );
  }

  void _playAlertSound() async {
    try {
      await audioPlayer.setVolume(1.0);
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource('sounds/alert.mp3'));
    } catch (e) {
      Get.snackbar('Error', 'Failed to play alert sound.');
    }
  }

  void _onDriverStatusChange(bool isOnline) {
    setState(() {
      this.isOnline = isOnline;
      if (isOnline) {
        _startAutoRefresh();
        _getCurrentLocation();
        _listenToTripRequests(); // Ensure listening to trip requests only when online
      } else {
        _stopAutoRefresh();
        _updateDriverStatus();
        audioPlayer.stop(); // Stop alert sound if offline
      }
    });
  }


  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 180), (Timer t) {
      if (isOnline) {
        _getCurrentLocation();
      }
    });
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 180), (Timer t) {
      if (isOnline) {
        _refreshPage();
      }
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  Future<void> _refreshPage() async {
    if (isManualRefreshCooldown) {
      Get.snackbar('Cooldown', 'Please wait before refreshing again.');
      return;
    }

    setState(() {
      isManualRefreshCooldown = true;
    });

    _fetchUserName();
    _getCurrentLocation();
    Get.snackbar('Refreshed', 'Page has been refreshed.');

    Timer(Duration(seconds: 30), () {
      setState(() {
        isManualRefreshCooldown = false;
      });
    });
  }

  void _updateDriverStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('driver_data')
          .doc(user.uid)
          .update({
        'status': isOnline ? 'online' : 'offline',
        'last_updated': Timestamp.now(),
      });
    }
  }

  void _startLocationCooldown() {
    _locationCooldownTimer?.cancel();
    _locationCooldownTimer = Timer(Duration(seconds: 10), () {
      setState(() {
        isManualRefreshCooldown = false;
      });
    });
    setState(() {
      isManualRefreshCooldown = true;
    });
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, String tooltip) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(
        icon,
        color: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green[50],
          elevation: 0,
          title: Row(
            children: [
              Text(
                userName.toUpperCase(),
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                isOnline ? "Online" : "Offline",
                style: TextStyle(color: Colors.black45),
              ),
              Switch(
                value: isOnline,
                onChanged: (value) {
                  _onDriverStatusChange(value);
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
            _initialPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom: 19.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
            if (isOnline)
              Positioned(
                top: 20,
                right: 20,
                child: _buildIconButton(
                  Icons.refresh,
                      () {
                    if (!isManualRefreshCooldown) {
                      _refreshPage();
                    }
                  },
                  'Refresh Page',
                ),
              ),
            if (isOnline)
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildIconButton(
                  Icons.my_location,
                      () {
                    if (!isManualRefreshCooldown) {
                      _getCurrentLocation();
                    } else {
                      Get.snackbar('Cooldown', 'Please wait before fetching location again.');
                    }
                  },
                  'Find My Location',
                ),
              ),
          ],
        ),
      ),
    );
  }
}