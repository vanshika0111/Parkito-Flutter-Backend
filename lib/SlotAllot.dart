import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SlotAllot extends StatefulWidget {
  final String documentId;

  SlotAllot({required this.documentId});

  @override
  _SlotAllotState createState() => _SlotAllotState();
}

class _SlotAllotState extends State<SlotAllot> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<int> vacantSlots = [];
  List<int> occupiedSlots = [];
  int? bookedSlot;

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
        addBookedSlotToFirestore(bookedSlot!);
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

  void addBookedSlotToFirestore(int bookedSlot) async {
    try {
      await firestore.collection('bookedData').doc(widget.documentId).update({
        'bookedSlot': bookedSlot,
      });
      print('Booked slot added to Firestore');
    } catch (error) {
      print('Error adding booked slot to Firestore: $error');
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
          ],
        ),
      ),
    );
  }
}


