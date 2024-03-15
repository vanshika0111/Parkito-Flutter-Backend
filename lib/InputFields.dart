import 'package:flutter/material.dart';
import "package:firebase_database/firebase_database.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:fluttertoast/fluttertoast.dart';


class InputFieldsScreen extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  void _sendDataToFirebase(String parkingArea, String vehicleNumber, String startDate, String startTime, String endDate, String endTime) {
    FirebaseFirestore.instance.collection('bookingDetails').add({
      'Parking Area': parkingArea,
      'Vehicle Number': vehicleNumber,
      'Start Date': startDate,
      'Start Time': startTime,
      'End Date': endDate,
      'End Time': endTime,
    })
        .then((value) {
      // Data added successfully
      Fluttertoast.showToast(
        msg: "Data sent to Firebase successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    })
        .catchError((error) {
      // Error adding data
      Fluttertoast.showToast(
        msg: "Failed to send data to Firebase: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController parkingAreaController = TextEditingController();
    TextEditingController vehicleNumberController = TextEditingController();
    TextEditingController startDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Fields'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: parkingAreaController,
                decoration: InputDecoration(labelText: 'Parking Area'),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: vehicleNumberController,
                decoration: InputDecoration(labelText: 'Vehicle Number'),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Start Time'),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: endDateController,
                decoration: InputDecoration(labelText: 'End Date'),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'End Time'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _sendDataToFirebase(
                    parkingAreaController.text,
                    vehicleNumberController.text,
                    startDateController.text,
                    startTimeController.text,
                    endDateController.text,
                    endTimeController.text,
                  );
                },
                child: Text('Send Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
