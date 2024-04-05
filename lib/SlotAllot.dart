import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SlotAllot extends StatefulWidget {
  final String documentId;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  SlotAllot({
    required this.documentId,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime
  });

  @override
  _SlotAllotState createState() => _SlotAllotState();
}

class _SlotAllotState extends State<SlotAllot> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<int> vacantSlots = [];
  List<int> occupiedSlots = [];
  int? bookedSlot;
  double? amountToPay;
  bool isCancelled = false;
  bool refundCalculated = false;
  double? refundAmount;

  @override
  void initState() {
    super.initState();
    fetchSlotData();
  }

  void fetchSlotData() async {
    try {
      // Retrieve the "Prototype" document
      DocumentSnapshot prototypeSnapshot =
      await firestore.collection('Prototype').doc('Prototype').get();

      if (prototypeSnapshot.exists) {
        // Extract slot data from the document
        Map<String, dynamic> slotData =
        prototypeSnapshot.data() as Map<String, dynamic>;
        print('Slots Data: $slotData');

        // Iterate over entries of the map to identify vacant and occupied slots
        slotData.entries.forEach((entry) {
          int slotNumber = int.parse(entry.key);
          dynamic slotStatus = entry.value;
          if (slotStatus == '0') {
            vacantSlots.add(slotNumber);
          } else if (slotStatus == '1') {
            occupiedSlots.add(slotNumber);
          }
        });

        print('Vacant Slots before booking: $vacantSlots');
        print('Occupied Slots before booking: $occupiedSlots');

        // Book the first available slot for the user
        if (vacantSlots.isNotEmpty) {
          bookedSlot = vacantSlots.first;
          vacantSlots.remove(bookedSlot);
          occupiedSlots.add(bookedSlot!);
          print('Booked Slot: $bookedSlot');

          slotData[bookedSlot.toString()] = '1';
          await firestore
              .collection('Prototype')
              .doc('Prototype')
              .update(slotData);
          setState(() {});
        }
        setState(() {
          this.amountToPay = calculateCost(
            widget.startDate,
            widget.startTime,
            widget.endDate,
            widget.endTime,
          );
        });
        addBookedSlotToFirestore(bookedSlot!, amountToPay ?? 0.0);
        print('Vacant Slots after booking: $vacantSlots');
        print('Occupied Slots after booking: $occupiedSlots');
        setState(() {});
      } else {
        print('Prototype document does not exist');
      }
    } catch (error) {
      print('Error fetching slot data: $error');
    }
  }

  double calculateCost(
      String startDate,
      String startTime,
      String endDate,
      String endTime,
      ) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

    // Parse date strings into DateTime objects
    DateTime startDateTime = dateFormat.parse('$startDate $startTime');
    DateTime endDateTime = dateFormat.parse('$endDate $endTime');

    print('Start Time for cost: ${dateFormat.format(startDateTime)}');
    print('End Time cost: ${dateFormat.format(endDateTime)}');

    final duration = endDateTime.difference(startDateTime);
    final minutes = duration.inMinutes;
    final costPerMinute = 0.1; // Cost per minute

    double amountToPay = minutes * costPerMinute;
    print('Cost: ${amountToPay}');
    return amountToPay;
  }

  void addBookedSlotToFirestore(int bookedSlot, double amountToPay) async {
    try {
      await firestore.collection('bookedData').doc(widget.documentId).update({
        'bookedSlot': bookedSlot,
        'amountToPay' : amountToPay,
      });
      print('Booked slot added to Firestore');
    } catch (error) {
      print('Error adding booked slot to Firestore: $error');
    }
  }

  void cancelBooking() async {
    try {
      // Remove booked slot from Firestore
      await firestore
          .collection('bookedData')
          .doc(widget.documentId)
          .update({'bookedSlot': 'Cancelled'});

      // Calculate refund amount (20% deduction)
      //double refundAmount = amountToPay != null ? amountToPay! * 0.2 : 0.0;
      double refundAmount = amountToPay != null ? amountToPay! * 0.8 : 0.0; // Calculate refund amount

      await firestore.collection('bookedData').doc(widget.documentId).update({
        'bookedSlot': 'Cancelled',
        'refundAmount': refundAmount, // Include refund amount in Firestore update
      });

      // Remove booked slot from local state
      occupiedSlots.remove(bookedSlot);
      vacantSlots.add(bookedSlot!);

      // Update slot status in Firestore
      Map<String, dynamic> slotData = {};
      occupiedSlots.forEach((slot) {
        slotData[slot.toString()] = '1';
      });
      vacantSlots.forEach((slot) {
        slotData[slot.toString()] = '0';
      });
      await firestore
          .collection('Prototype')
          .doc('Prototype')
          .update(slotData);

      setState(() {
        isCancelled = true;
        refundCalculated = true;
        this.refundAmount = refundAmount;
      });
      print('Booking canceled. Refund amount: $refundAmount');
    } catch (error) {
      print('Error canceling booking: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Allotment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document ID:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.documentId,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Booked Slot:', // Display the booked slot number
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              this.bookedSlot != null
                  ? this.bookedSlot.toString()
                  : 'No slot booked',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Amount to Pay:', // Display the amount to pay
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              amountToPay != null
                  ? 'Rs. ${amountToPay!.toStringAsFixed(2)}' // Display the amount to pay formatted with 2 decimal places
                  : 'Amount not calculated',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: bookedSlot != null ? cancelBooking : null,
              child: Text('Cancel Booking'),
            ),
            SizedBox(height: 20),
            if (isCancelled) ...[
              Text(
                'Refund Amount:', // Display the refund amount
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                refundAmount != null
                    ? 'Rs. ${refundAmount!.toStringAsFixed(2)}' // Display the refund amount formatted with 2 decimal places
                    : 'Amount not calculated',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
