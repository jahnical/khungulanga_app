import 'package:flutter/material.dart';
import 'package:khungulanga_app/models/appointment_chat.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'appointment_chat_page.dart';

/// Deprecated page.
/// A page that displays a list of appointment chats.
class AppointmentChats extends StatelessWidget {
  final AppointmentRepository appointmentChatRepository =
  AppointmentRepository();

  AppointmentChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Chats')),
      body: FutureBuilder<List<AppointmentChat>>(
        future: appointmentChatRepository.getAppointmentChats(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final appointmentChats = snapshot.data!;

            return ListView.builder(
              itemCount: appointmentChats.length,
              itemBuilder: (context, index) {
                final chat = appointmentChats[index];
                final lastMessage = chat.messages.isNotEmpty
                    ? chat.messages.last.text
                    : 'No messages yet';

                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person),
                  ),
                  title: Text(chat.dermatologist.user.firstName),
                  subtitle: Text(lastMessage),
                  trailing: chat.messages.isNotEmpty
                      ? Icon(
                    chat.messages.last.seen
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: chat.messages.last.seen
                        ? Colors.green
                        : Colors.grey,
                  )
                      : null,
                  onTap: () {
                    // Navigate to the appointment chat page
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AppointmentChatPage(dermatologist: chat.dermatologist,))
                    ); 
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
