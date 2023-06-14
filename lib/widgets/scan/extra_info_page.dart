import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/repositories/diagnosis_repository.dart';
import 'package:khungulanga_app/util/common.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnosis_page.dart';

class ExtraInfoPage extends StatefulWidget {
  final String imagePath;

  const ExtraInfoPage({required this.imagePath, Key? key}) : super(key: key);

  @override
  _ExtraInfoPageState createState() => _ExtraInfoPageState();
}

class _ExtraInfoPageState extends State<ExtraInfoPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBodyPart = "Face";
  bool _isItchy = false;

  void _onSubmitForm(BuildContext context, DiagnosisBloc bloc, {bool ignoreSkin = false}) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = FormData.fromMap({
        'body_part': _selectedBodyPart,
        'itchy': _isItchy,
        'ignore_skin': ignoreSkin,
        'image':  await MultipartFile.fromFile(widget.imagePath),
      });

      bloc.add(Diagnose(formData));
    }
  }

  void _showAlertDialog(String title, String content, List<TextButton> actions) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: actions,
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        if (state is DiagnosingError206) {
          _showAlertDialog(
            "Warning",
            state.message + "\n\nThe diagnosis may not be accurate. Do you want to continue?",
            [TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                  _onSubmitForm(context, BlocProvider.of<DiagnosisBloc>(context), ignoreSkin: true),
                },
                child: const Text('Diagnose anyway'),),
            ],);
        } else if (state is DiagnosingErrorAny) {
          _showAlertDialog(
            "Error",
            state.message,
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],);
        } else if (state is DiagnosisSuccess) {
          // Navigate to the success page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiagnosisPage(
                diagnosis: state.diagnosis,
              ),
            ),
          );
          BlocProvider.of<DiagnosisBloc>(context).add(FetchDiagnoses());
        }
      },
      child: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          return Scaffold(
                appBar: AppBar(title: const Text('Diagnosis Info')),
                body: Column(
                  children: [
                    Expanded(
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 2.0),
                            const Text(
                              'Select body part:',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 2.0),
                            DropdownButtonFormField<String>(
                              value: _selectedBodyPart,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Face',
                                  child: Text('Face'),
                                ),
                                DropdownMenuItem(
                                  value: 'Upper Body',
                                  child: Text('Upper Body'),
                                ),
                                DropdownMenuItem(
                                  value: 'Arms Hands',
                                  child: Text('Arms or Hands')
                                ),
                                DropdownMenuItem(
                                  value: 'Legs Feet',
                                  child: Text('Feet or Legs'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedBodyPart = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a body part';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            const Text(
                              'Is it itchy?',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 0.0),
                            SwitchListTile(
                              value: _isItchy,
                              onChanged: (value) {
                                setState(() {
                                  _isItchy = value;
                                });
                              },
                              title: Text(_isItchy ? 'Yes' : 'No'),
                            ),
                            const SizedBox(height: 24.0),
                            ElevatedButton(
                              onPressed: state is Diagnosing ? null : () => { _onSubmitForm(context, BlocProvider.of<DiagnosisBloc>(context)) },
                              style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all<Size>(
                                  const Size(double.infinity, 60),
                                ),
                              ),
                              child: state is Diagnosing ? const CircularProgressIndicator() : const Text('Diagnose'),
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }
}
