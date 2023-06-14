import 'dart:developer';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/chat_message.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/common/common.dart';

import '../../blocs/appointment_bloc/appointment_chat_bloc.dart';
import '../../models/dermatologist.dart';
import '../../models/diagnosis.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../diagnosis/diagnosis_page.dart';



class AppointmentChatPage extends StatefulWidget {
  final Dermatologist dermatologist;
  Diagnosis? diagnosis;

  AppointmentChatPage({
    required this.dermatologist,
    this.diagnosis,
  });

  @override
  _AppointmentChatPageState createState() => _AppointmentChatPageState();
}

class _AppointmentChatPageState extends State<AppointmentChatPage> {
  late TextEditingController _messageController;
  late AppointmentChatBloc _bloc;

  late TextEditingController durationController;
  late TextEditingController costController;
  late TextEditingController extraInfoController;
  late TextEditingController dateController;
  bool isDirty = false;


  @override
  void initState() {
    super.initState();
    _bloc = AppointmentChatBloc(
        RepositoryProvider.of<AppointmentRepository>(context),
        RepositoryProvider.of<UserRepository>(context)
    )..add(FetchAppointmentChat(null, widget.dermatologist, null, context, widget.diagnosis));
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    durationController.dispose();
    costController.dispose();
    extraInfoController.dispose();
    super.dispose();
  }

  void fieldChanged() {
    _bloc.chatAppointmentIsDirty = _bloc.chat?.appointment.appoTime.toString() != dateController.text
        || _bloc.chat!.appointment.cost.toString() != costController.text
        || _bloc.chat!.appointment.duration?.inHours.toString() != durationController.text
        || _bloc.chat!.appointment.extraInfo != extraInfoController.text;
    setState(() {
      isDirty = _bloc.chatAppointmentIsDirty;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      sender: _bloc.chat!.patient.user!,
      text: _messageController.text.trim(),
      chatId: _bloc.chat!.id!,
      time: DateTime.now(),
      seen: false,
    );

    final data = FormData.fromMap(newMessage.toJsonMap());


    _bloc.add(SendMessage(data));
  }

  bool _isExpanded = false;
  bool initialized = false;
  Widget _buildAppointmentCard() {
    if (!initialized) {
      durationController = TextEditingController(text: _bloc.chat!.appointment.duration?.inHours.toString());
      costController = TextEditingController(text: _bloc.chat!.appointment.cost.toString());
      extraInfoController = TextEditingController(text: _bloc.chat!.appointment.extraInfo);
      dateController = TextEditingController(text: _bloc.chat!.appointment.appoTime?.toString());
      initialized = true;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _bloc.state is UpdatingAppointment ? const LoadingIndicator() : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointment Details',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              _bloc.state is UpdatingAppointment? const LoadingIndicator() : Column(
                children: [
                  const SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: '${_bloc.chat!.appointment.diagnosis?.predictions.first.disease.name ?? "No Diagnosis"} ${_bloc.chat!.appointment.diagnosis != null? '${DateFormat('dd/MM/yyyy').format(_bloc.chat!.appointment.diagnosis!.date)})' : ""}',
                    decoration: const InputDecoration(labelText: 'Diagnosis'),
                    enabled: false,
                    readOnly: true,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DiagnosisPage(diagnosis: _bloc.chat!.appointment.diagnosis!),
                      ));
                    },
                  ),
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Select Time',
                      suffixIcon: IconButton(
                        onPressed: () => _showDateTimePicker(),
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    onTap: () {
                      _showDateTimePicker();
                    },
                    readOnly: true,
                  ),
                  TextFormField(
                    controller: durationController..addListener(fieldChanged),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Duration (hours)'),
                    keyboardType: const TextInputType.numberWithOptions(),
                  ),
                  TextFormField(
                    controller: costController..addListener(fieldChanged),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Cost'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextFormField(
                    controller: extraInfoController..addListener(fieldChanged),
                    decoration: const InputDecoration(labelText: 'Extra Information'),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: !_bloc.chatAppointmentIsDirty? null : !isDirty ? null : () {
                          updateAppointment();
                        },
                        child: const Text('Update'),
                      ),
                      const Expanded(child: SizedBox(),),
                      ElevatedButton(
                        onPressed: _bloc.chat!.appointment.patientApproved != null? null :  () {
                          _bloc.add(ApproveAppointment());
                        },
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 16.0,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: _bloc.chat!.appointment.patientRejected != null? null : () {
                          _bloc.add(RejectAppointment());
                        },
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDateTimePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          if (selectedTime != null) {
            final DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            dateController.text = selectedDateTime.toString();
            fieldChanged();
          }
        });
      }
    });
  }


  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: _bloc.chat!.messages.length,
      itemBuilder: (context, index) {
        final message = _bloc.chat!.messages[index];
        return Row(
          mainAxisAlignment: message.sender.username == USER?.username ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: message.sender.username == USER?.username ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    timeago.format(message.time), // Assuming 'time' is the property representing the message time
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ],
              ),
            ),
            Icon(
              message.seen ? Icons.check_circle : Icons.check_circle_outline,
              color: message.seen ? Colors.green : Colors.grey,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => {_sendMessage()},
              child: _bloc.state is AppointmentChatMessageSending? const LoadingIndicator() : const Icon(Icons.send),
            ),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentChatBloc, AppointmentChatState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is AppointmentChatInitial || state is AppointmentChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('${_bloc.chat!.dermatologist.user.firstName} ${_bloc.chat!.dermatologist.user.lastName}'),
            ),
            body: Column(
              children: [
                _buildAppointmentCard(),
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
          );
        }
      },
    );
  }

  void updateAppointment() {
    final appointment = _bloc.chat!.appointment.copyWith(
        extraInfo: extraInfoController.text,
        cost: double.tryParse(costController.text),
        duration: Duration(hours: int.tryParse(durationController.text) ?? 0),
        appoDate: DateTime.parse(dateController.text)
    );
    _bloc.add(UpdateAppointment(appointment));
    fieldChanged();
  }
}