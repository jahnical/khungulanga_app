import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/repositories/diagnosis_repository.dart';
import 'package:khungulanga_app/util/common.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnosis_page.dart';

/// A page for providing extra information related to a diagnosis.
class ExtraInfoPage extends StatefulWidget {
  final String imagePath;

  /// Constructs an ExtraInfoPage with the provided [imagePath].
  const ExtraInfoPage({required this.imagePath, Key? key}) : super(key: key);

  @override
  _ExtraInfoPageState createState() => _ExtraInfoPageState();
}

/// The state for the ExtraInfoPage.
class _ExtraInfoPageState extends State<ExtraInfoPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBodyPart = "Face";
  bool _isItchy = false;
  late CancelToken _cancelToken;

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  /// Handles the form submission and triggers the diagnosis process.
  void _onSubmitForm(BuildContext context, DiagnosisBloc bloc, {bool ignoreSkin = false}) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = FormData.fromMap({
        'body_part': _selectedBodyPart,
        'itchy': _isItchy,
        'ignore_skin': ignoreSkin,
        'image': await MultipartFile.fromFile(widget.imagePath),
      });

      bloc.add(Diagnose(formData, cancelToken: _cancelToken));
    }
  }

  /// Shows a dialog with a loading indicator while diagnosing.
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Diagnosing...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('Please wait...'),
            ],
          ),
          actions: [
            /*TextButton(
              onPressed: () {
                _cancelToken.cancel();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),*/
          ],
        );
      },
    );
  }

  /// Shows an alert dialog with the provided [title], [content], and [actions].
  void _showAlertDialog(String title, String content, List<TextButton> actions) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        if (state is DiagnosingError206) {
          Navigator.of(context).pop();
          _showAlertDialog(
            "Warning",
            state.message + "\n\nThe diagnosis may not be accurate. Do you want to continue?",
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _onSubmitForm(context, BlocProvider.of<DiagnosisBloc>(context), ignoreSkin: true);
                },
                child: const Text('Diagnose anyway'),
              ),
            ],
          );
        } else if (state is DiagnosingErrorAny) {
          Navigator.of(context).pop();
          _showAlertDialog(
            "Error",
            state.message,
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        } else if (state is DiagnosisSuccess) {
          // Navigate to the success page
          Navigator.of(context).pop();
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
                        Row(
                          children: [
                            Text(
                              'Select body part:',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            Expanded(child: Container()),
                            IconButton(
                                onPressed: _bodyPartInfo, icon: Icon(Icons.info_outline), tooltip: 'Body Part Info'),
                          ],
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
                              child: Text('Upper Body (+ Cranium)'),
                            ),
                            DropdownMenuItem(
                              value: 'Arms Hands',
                              child: Text('Arms or Hands'),
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
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: state is Diagnosing ? null : () {
                            _showLoadingDialog(context);
                            _onSubmitForm(context, BlocProvider.of<DiagnosisBloc>(context));
                          },
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

  /// Shows a dialog with information about body parts.
  void _bodyPartInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Body Part Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select the body part that is affected by the skin condition. If the skin condition affects multiple body parts, select the body part that is most affected.',
                ),
                const SizedBox(height: 16.0),
                Text(
                  'For example, if the skin condition affects the face and the upper body, select "Face".',
                ),
                const SizedBox(height: 24.0),
                Text(
                  'The selected body part will be used to narrow down the diagnosis as follows:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Face: Acne Vulgaris, Basal Cell Carcinoma, Rosacea, Squamous Cell Carcinoma, Urticaria',
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Upper Body (+ Cranium): Acne Vulgaris, Basal Cell Carcinoma, Folliculitis, Lichen Planus, Psoriasis, Rosacea, Scabies',
                ),
                const SizedBox(height: 16.0),
                Text(
                    'Arms or Hands: Basal Cell Carcinoma, Allergic Contact Dermatitis, Lichen Planus, Psoriasis, Scabies, Urticaria'
                ),
                const SizedBox(height: 16.0),
                Text(
                    'Legs or Feet: Basal Cell Carcinoma, Folliculitis, Melanoma, Psoriasis, Scabies'
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
