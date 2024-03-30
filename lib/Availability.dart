import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Availability extends StatefulWidget {
  @override
  _AvailabilityState createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String docId;
  Map<String, dynamic>? bookingDetails;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String availabilityStatus = '';

  @override
  void initState() {
    super.initState();
    fetchDocId();
  }

  void fetchDocId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      docId = prefs.getString('docId') ?? '';
    });
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      DocumentSnapshot docSnapshot =
      await firestore.collection('bookingDetails').doc(docId).get();
      setState(() {
        bookingDetails = docSnapshot.data() as Map<String, dynamic>?;
      });
      calculateAvailability();
    } catch (e) {
      print("Error getting document: $e");
    }
  }

  void calculateAvailability() {
    if (bookingDetails != null) {
      // Extract relevant data from bookingDetails
      String startDate = bookingDetails!['startDate'];
      String startTime = bookingDetails!['startTime'];
      String endDate = bookingDetails!['endDate'];
      String endTime = bookingDetails!['endTime'];

      // Parse date strings into DateTime objects
      DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm'); // Define date format
      DateTime startDateTime = dateFormat.parse('$startDate $startTime');
      DateTime endDateTime = dateFormat.parse('$endDate $endTime');

      // Fetch slot information from Firestore
      CollectionReference prototypeCollection = firestore.collection('Prototype');
      prototypeCollection.doc('Prototype').get().then((docSnapshot) {
        if (docSnapshot.exists) {
          Map<String, dynamic> slotsData = docSnapshot.data() as Map<String, dynamic>;
          int totalSlots = slotsData.length;
          int availableSlots = slotsData.values.where((value) => value == 0).length;

          // Adjust start and end times for availability check
          DateTime startCheckTime = startDateTime.subtract(Duration(minutes: 15));
          DateTime endCheckTime = endDateTime.add(Duration(minutes: 30));

          // Perform availability check
          if (startCheckTime.isBefore(endCheckTime)) {
            if (availableSlots > 0 && availableSlots < totalSlots) {
              setState(() {
                availabilityStatus = 'Slot available';
              });
            } else {
              setState(() {
                availabilityStatus = 'Slot not available, choose another time slot';
              });
            }
          } else {
            setState(() {
              availabilityStatus = 'Invalid time slot';
            });
          }
        } else {
          setState(() {
            availabilityStatus = 'Prototype document not found';
          });
        }
      }).catchError((error) {
        setState(() {
          availabilityStatus = 'Error fetching data: $error';
        });
      });
    } else {
      setState(() {
        availabilityStatus = 'Booking details not available';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Availability'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Document ID: $docId'),
            SizedBox(height: 20),
            if (availabilityStatus.isNotEmpty)
              Text('Availability Status: $availabilityStatus'),
            if (bookingDetails == null)
              Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
