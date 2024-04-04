import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:parkito_backend_flutter/BookConfirm.dart';
import 'BookConfirm.dart';

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

  bool isSubmitEnabled = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the input fields
    startDateController.addListener(checkSubmitButton);
    startTimeController.addListener(checkSubmitButton);
    endDateController.addListener(checkSubmitButton);
    endTimeController.addListener(checkSubmitButton);
  }

  @override
  void dispose() {
    // Dispose text editing controllers
    parkingAreaController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  // Function to check if the submit button should be enabled
  void checkSubmitButton() {
    setState(() {
      isSubmitEnabled = startDateController.text.isNotEmpty &&
          startTimeController.text.isNotEmpty &&
          endDateController.text.isNotEmpty &&
          endTimeController.text.isNotEmpty;
      if (isSubmitEnabled) {
        checkParkingSlotAvailability();
      }
    });
  }

  // Function to fetch data from Firestore and check parking slot availability
  Future<bool> checkParkingSlotAvailability() async {
    String startDate = startDateController.text;
    String startTime = startTimeController.text;
    String endDate = endDateController.text;
    String endTime = endTimeController.text;

    try {
      // Fetch data from Firestore collection 'Prototype'
      DocumentSnapshot prototypeSnapshot =
      await firestore.collection('Prototype').doc('Prototype').get();

      if (prototypeSnapshot.exists) {
        if (prototypeSnapshot.data() is Map<String, dynamic>) {
          // Extract slot data from Firestore document
          Map<String, dynamic> slotsData =
          prototypeSnapshot.data() as Map<String, dynamic>; // Assuming slotsData is a map
          print('Slots Data: $slotsData');

          bool isSlotAvailable = checkSlotAvailability(
              startDate, startTime, endDate, endTime, slotsData);
          if (isSlotAvailable) {
            print('Slot is available for the specified time.');
            return true;
          } else {
            print('Slot is not available for the specified time.');
            Fluttertoast.showToast(
                msg: "Slot not available",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return false;
          }
        } else {
          print('Firestore data is not a map');
          return false;
        }
      } else {
        print('Prototype document not found');
        return false;
      }
    } catch (error) {
      print('Error fetching data: $error');
      return false;
    }
  }

  bool checkSlotAvailability(String startDate, String startTime,
      String endDate, String endTime, Map<String, dynamic> slotsData) {
    // Define date format
    DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

    // Parse date strings into DateTime objects
    DateTime startDateTime = dateFormat.parse('$startDate $startTime');
    DateTime endDateTime = dateFormat.parse('$endDate $endTime');

    print('Start Time fetched: ${dateFormat.format(startDateTime)}');
    print('End Time fetched: ${dateFormat.format(endDateTime)}');

    // Adjust start and end times for availability check
    DateTime startCheckTime = startDateTime.subtract(Duration(minutes: 15));
    DateTime endCheckTime = endDateTime.add(Duration(minutes: 30));

    print('Start Time calculated: ${dateFormat.format(startCheckTime)}');
    print('End Time calculated: ${dateFormat.format(endCheckTime)}');

    // Perform availability check
    List<int> intArray =
    slotsData.values.map((value) => int.parse(value.toString())).toList();
    int total = slotsData.length;
    int a = 0;
    for (int i = 0; i < total; i++) {
      a += intArray[i];
    }
    int available = total - a;
    print('Available slots: $available  ---------- Total Slots: $total');

    if (startCheckTime.isBefore(endCheckTime)) {
      if (available < total && available > 0) {
        print("Slot is available");
        return true;
      } else {
        print("Slot is not available");
        return false;
      }
    } else {
      print("Invalid time slot");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Fields'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                onPressed: isSubmitEnabled
                    ? () async {
                  bool isAvailable =
                  await checkParkingSlotAvailability();
                  if (isAvailable) {
                    print('Proceed to payment');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookConfirm(
                          parkingArea: parkingAreaController.text,
                          startDate: startDateController.text,
                          startTime: startTimeController.text,
                          endDate: endDateController.text,
                          endTime: endTimeController.text,
                        ),
                      ),
                    );
                  } else {
                    print('Cannot proceed with the payment');
                    Fluttertoast.showToast(
                        msg: "Cannot proceed with the payment",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }
                    : null,
                child: Text('Proceed to pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
