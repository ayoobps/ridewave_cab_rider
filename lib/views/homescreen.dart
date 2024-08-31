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
  bool isOnline = false;
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
    _startLocationUpdates();
    _listenToNewTripRequests();
    _updateDriverStatus(); // Update driver status in Firestore
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

    // Update location in Firebase
    _updateLocationInFirebase(position);
  }

  //*************
  Future<void> _updateLocationInFirebase(Position position) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update the driver's location and status in the driver_data collection
        await FirebaseFirestore.instance
            .collection('driver_data')
            .doc(user.uid)
            .update({
          'current_location': GeoPoint(position.latitude, position.longitude),
          'last_updated': Timestamp.now(),
          'status': isOnline ? 'online' : 'offline',
        });

        // Check if the current driver is selected in the trip-from-user collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('trip-from-user')
            .where('driver_id', isEqualTo: user.uid)
            .where('selected', isEqualTo: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Assuming there might be multiple trips but we only care about the current one
          for (var doc in querySnapshot.docs) {
            var tripData = doc.data() as Map<String, dynamic>?;

            if (tripData != null) {
              _showTripData(tripData); // Show trip data if the current driver is selected
              break; // Show alert for the first matching trip and exit the loop
            }
          }
        } else {
          print("No active trips for the current driver.");
        }
      }
    } catch (e) {
      print("Failed to update location in Firebase: $e");
      Get.snackbar('Error', 'Failed to update location.');
    }
  }


  //*******
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
            "You have a new trip request.",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
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
        audioPlayer.stop(); // Stop the alert sound when "OK" is clicked
        Get.offNamed('/newtripalert', arguments: tripData);
      },
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      buttonColor: Colors.green,
    );
  }



  void _onDriverStatusChange(bool isOnline) {
    setState(() {
      this.isOnline = isOnline;
      _getCurrentLocation(); // Fetch current location and trigger the update
    });
  }


  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      _getCurrentLocation();
    });
  }

  void _playAlertSound() async {
    try {
      await audioPlayer.setVolume(1.0);
      await audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the sound
      await audioPlayer.play(AssetSource('sounds/alert.mp3'));
    } catch (e) {
      Get.snackbar('Error', 'Failed to play alert sound.');
    }
  }

  void _showNewTripAlertDialog(Map<String, dynamic> tripData) {
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
            "Pickup: ${tripData['pickup_place']}",
            style: TextStyle(fontSize: 16.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Text(
            "Drop: ${tripData['drop_place']}",
            style: TextStyle(fontSize: 16.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      onConfirm: () {
        audioPlayer.stop(); // Stop the alert sound when "OK" is clicked
        Get.offNamed('/newtripalert', arguments: tripData);
      },
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      buttonColor: Colors.green,
    );
  }


  //******
  void _listenToNewTripRequests() {
    FirebaseFirestore.instance.collection('trips-from-user').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var newTrip = change.doc.data() as Map<String, dynamic>?;
          print('New Trip Data: $newTrip'); // Log the new trip data

          if (newTrip != null) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (newTrip['driver_id'] == user.uid && newTrip['selected'] == true) {
                _playAlertSound();
                _showTripData(newTrip);
              }
            }
          }
        }
      });
    });
  }


  Future<void> _refreshPage() async {
    _fetchUserName();
    _getCurrentLocation();
    Get.snackbar('Refreshed', 'Page has been refreshed.');
  }

  void _updateDriverStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('driver_data')
          .doc(user.uid)
          .update({
        'status': isOnline ? 'online' : 'offline',
      });
    }
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
    // Initialize ScreenUtil for responsive design
    return ScreenUtilInit(
      designSize: Size(375, 812),
      child:  Scaffold(
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
              Spacer(),
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
            if (isOnline)
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
            Positioned(
              top: 20,
              right: 20,
              child: _buildIconButton(
                Icons.refresh,
                _refreshPage,
                'Refresh Page',
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildIconButton(
                Icons.my_location,
                _getCurrentLocation,
                'Find My Location',
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
      ),
    );
  }
}