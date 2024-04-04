import 'package:flutter/material.dart';
import 'package:parkito_backend_flutter/SlotAllot.dart';
import 'SlotAllot.dart'; // Import the Availability screen

class BookConfirm extends StatefulWidget {
  @override
  _BookConfirmState createState() => _BookConfirmState();
}

class _BookConfirmState extends State<BookConfirm> {
  TextEditingController vehicleNumberController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    vehicleNumberController.dispose();
    super.dispose();
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
            onPressed: () {
              // Handle 'Yes' button press
              // Navigate to the Availability screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SlotAllot()),
              );
            },
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
