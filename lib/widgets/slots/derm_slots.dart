import 'package:flutter/material.dart';


class DermatologistSlotsPage extends StatelessWidget {
  final List<String> slots = [
    'Slot 1: 9:00 AM - 10:00 AM',
    'Slot 2: 10:30 AM - 11:30 AM',
    'Slot 3: 1:00 PM - 2:00 PM',
    'Slot 4: 2:30 PM - 3:30 PM',
    'Slot 5: 4:00 PM - 5:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: slots.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(slots[index]),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Slot Selected'),
                    content: Text('You have selected ${slots[index]}'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding a new slot here
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
