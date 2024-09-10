import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IkkawaScreen extends StatefulWidget {
  const IkkawaScreen({super.key});

  @override
  State<IkkawaScreen> createState() => _IkkawaScreenState();
}

class _IkkawaScreenState extends State<IkkawaScreen> {



  @override
  Widget build(BuildContext context) {
    return const Placeholder(


    );
  }
  Future<void> createData() async {
    CollectionReference ikkawatable = FirebaseFirestore.instance.collection('ikkawa');


    // Add a new document with a generated ID
    await ikkawatable.add({
      'user_name': 'AYOOB PS',
      'user_phone': 9020111414,
      'user_email': 'ayoobps2018@gmail.com',
    }).then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
