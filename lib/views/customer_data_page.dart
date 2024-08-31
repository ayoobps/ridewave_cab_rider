import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDataPage extends StatefulWidget {
  @override
  _CustomerDataPageState createState() => _CustomerDataPageState();
}

class _CustomerDataPageState extends State<CustomerDataPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers for various inputs
  final TextEditingController _tripIdController = TextEditingController();
  final TextEditingController _pickupLatController = TextEditingController();
  final TextEditingController _pickupLngController = TextEditingController();
  final TextEditingController _dropLatController = TextEditingController();
  final TextEditingController _dropLngController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();

  double? _distanceInKm;
  double _totalAmount = 0.0;
  double _fareAmount = 0.0;
  int _token = 0;

  @override
  void dispose() {
    _tripIdController.dispose();
    _pickupLatController.dispose();
    _pickupLngController.dispose();
    _dropLatController.dispose();
    _dropLngController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  void _calculateFare() {
    const double minimumCharge = 140;
    const double perKmCharge = 15;
    const double minimumKm = 2;
    const double peakHourSurge = 0.2;

    double pickupLat = double.tryParse(_pickupLatController.text) ?? 0.0;
    double pickupLng = double.tryParse(_pickupLngController.text) ?? 0.0;
    double dropLat = double.tryParse(_dropLatController.text) ?? 0.0;
    double dropLng = double.tryParse(_dropLngController.text) ?? 0.0;

    // Calculate the distance between pickup and drop locations
    _distanceInKm = Geolocator.distanceBetween(
        pickupLat, pickupLng, dropLat, dropLng) /
        1000;

    if (_distanceInKm != null) {
      double extraKm = (_distanceInKm! > minimumKm) ? _distanceInKm! - minimumKm : 0;
      _fareAmount = minimumCharge + (extraKm * perKmCharge);

      // Add peak hour surge if applicable
      bool isPeakHour = _isPeakHour();
      if (isPeakHour) {
        _fareAmount += _fareAmount * peakHourSurge;
      }

      double tip = double.tryParse(_tipController.text) ?? 0.0;
      _totalAmount = _fareAmount + tip;
    }

    setState(() {});
  }

  bool _isPeakHour() {
    // Define peak hours (e.g., 8 AM - 10 AM and 5 PM - 7 PM)
    TimeOfDay now = TimeOfDay.now();
    if ((now.hour >= 8 && now.hour <= 10) || (now.hour >= 17 && now.hour <= 19)) {
      return true;
    }
    return false;
  }

  Future<void> _saveToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'trip_id': _tripIdController.text,
        'customer_name': _customerNameController.text,
        'customer_address': _customerAddressController.text,
        'customer_phone': _customerPhoneController.text,
        'customer_email': _customerEmailController.text,
        'pickup_location': GeoPoint(
          double.parse(_pickupLatController.text),
          double.parse(_pickupLngController.text),
        ),
        'drop_location': GeoPoint(
          double.parse(_dropLatController.text),
          double.parse(_dropLngController.text),
        ),
        'distance_km': _distanceInKm,
        'fare_amount': _fareAmount,
        'tip': double.tryParse(_tipController.text) ?? 0.0,
        'total_amount': _totalAmount,
        'confirmation_token': _token,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order added successfully!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add order: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Data Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tripIdController,
                decoration: InputDecoration(labelText: 'Trip ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Trip ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerNameController,
                decoration: InputDecoration(labelText: 'Customer Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerAddressController,
                decoration: InputDecoration(labelText: 'Customer Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerPhoneController,
                decoration: InputDecoration(labelText: 'Customer Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerEmailController,
                decoration: InputDecoration(labelText: 'Customer Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pickupLatController,
                decoration: InputDecoration(labelText: 'Pickup Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pickupLngController,
                decoration: InputDecoration(labelText: 'Pickup Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dropLatController,
                decoration: InputDecoration(labelText: 'Drop Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter drop latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dropLngController,
                decoration: InputDecoration(labelText: 'Drop Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter drop longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tipController,
                decoration: InputDecoration(labelText: 'Tip (in Rupees)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _token = (1000 + (9999 - 1000) * (new DateTime.now().millisecondsSinceEpoch % 1000)).round();
                    _calculateFare();
                    _saveToFirestore();
                  }
                },
                child: Text('Calculate Fare and Save Order'),
              ),
              SizedBox(height: 20.h),
              if (_distanceInKm != null) ...[
                Text(
                  'Distance: ${_distanceInKm!.toStringAsFixed(2)} km',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Fare: \u{20B9}${_fareAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Total Amount: \u{20B9}${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '4-Digit Token: $_token',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
