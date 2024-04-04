import 'package:flutter/material.dart';
import 'SlotAllot.dart'; // Import the SlotAllot screen
import 'package:cloud_firestore/cloud_firestore.dart';

class BookConfirm extends StatefulWidget {
  final String parkingArea;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  BookConfirm({
    required this.parkingArea,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  });

  @override
  _BookConfirmState createState() => _BookConfirmState();
}

class _BookConfirmState extends State<BookConfirm> {
  TextEditingController vehicleNumberController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    vehicleNumberController.dispose();
    super.dispose();
  }

  void _saveDataAndNavigate() async {
    // Get vehicle number from the text field
    String vehicleNumber = vehicleNumberController.text;

    try {
      // Save data to Firestore collection 'bookedData' and get the document ID
      DocumentReference documentReference = await firestore.collection('bookedData').add({
        'parkingArea': widget.parkingArea,
        'startDate': widget.startDate,
        'startTime': widget.startTime,
        'endDate': widget.endDate,
        'endTime': widget.endTime,
        'vehicleNumber': vehicleNumber,
      });

      // Navigate to the SlotAllot screen and pass the document ID as an argument
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotAllot(documentId: documentReference.id),
        ),
      );
    } catch (error) {
      print('Error saving data: $error');
      // Handle error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Confirmation'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Do you want to book the slot with the details filled in the previous screen?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _saveDataAndNavigate, // Call function to save data and navigate
            child: Text('Yes'),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Handle 'No' button press
              // Navigate back to the previous screen
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }
}
