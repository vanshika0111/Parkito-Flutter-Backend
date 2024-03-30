import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Availability.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputFields extends StatefulWidget {
  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  final TextEditingController parkingAreaController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendDataAndNavigateToAvailabilityScreen() async {
    try {
      DocumentReference docRef = await firestore.collection('bookingDetails').add({
        'parkingArea': parkingAreaController.text,
        'startDate': startDateController.text,
        'startTime': startTimeController.text,
        'endDate': endDateController.text,
        'endTime': endTimeController.text,
      });

      // Clear text fields after sending data
      parkingAreaController.clear();
      startDateController.clear();
      startTimeController.clear();
      endDateController.clear();
      endTimeController.clear();

      // Get the document ID of the newly created document
      String docId = docRef.id;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('docId', docId);

      // Show toast message
      Fluttertoast.showToast(msg: "Data sent to Firestore successfully");

      // Navigate to the Availability screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Availability(),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Data not sent to Firestore successfully");
      print("Error adding document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Fields'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: parkingAreaController,
                decoration: InputDecoration(labelText: 'Parking Area'),
              ),
              TextField(
                controller: startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
              ),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Start Time'),
              ),
              TextField(
                controller: endDateController,
                decoration: InputDecoration(labelText: 'End Date'),
              ),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'End Time'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => sendDataAndNavigateToAvailabilityScreen(),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
