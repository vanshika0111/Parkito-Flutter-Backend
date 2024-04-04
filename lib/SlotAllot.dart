import 'package:flutter/material.dart';

class SlotAllot extends StatelessWidget {
  final String documentId;

  SlotAllot({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Allotment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Document ID:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              documentId,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
