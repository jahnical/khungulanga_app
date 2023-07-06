import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/treatment.dart';

import '../../blocs/diagnosis_bloc/diagnosis_bloc.dart';
import '../../models/diagnosis.dart';
import '../../models/prediction.dart';
import '../../util/common.dart';

/// A page that displays detailed information about a specific diagnosis. It also allows the user to confirm the diagnosis.
class ConfirmationPage extends StatefulWidget {
  final Prediction prediction;
  final Diagnosis diagnosis;

  ConfirmationPage({required this.prediction, required this.diagnosis});

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

/// The state of the [ConfirmationPage].
class _ConfirmationPageState extends State<ConfirmationPage> {
  TextEditingController treatmentController = TextEditingController();
  bool isTreatmentFilled = false;
  Treatment? selectedTreatment;

  @override
  void dispose() {
    treatmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    treatmentController.addListener(() {
      setState(() {
        isTreatmentFilled = treatmentController.text.isNotEmpty;
      });
    });
    selectedTreatment = widget.prediction.treatmentId != null
        ? widget.prediction.disease.treatments.firstWhere((element) => element.id == widget.prediction.treatmentId)
        : null;
  }

  /// Handles the refer treatment button.
  void handleReferTreatment() {
    // Refer treatment
    Navigator.pop(context);
    context.read<DiagnosisBloc>().add(
      ReferTreatmentPressed(
        diagnosis: widget.diagnosis,
        prediction: widget.prediction,
      ),
    );
  }

  /// Handles the submit treatment button.
  void handleSubmitTreatment() {
    //Navigator.pop(context);
    if (isTreatmentFilled || selectedTreatment != null) {
      // Submit treatment
      final treatment = treatmentController.text;
      widget.prediction.treatmentId = selectedTreatment?.id;
      context.read<DiagnosisBloc>().add(
        SubmitTreatmentPressed(
          diagnosis: widget.diagnosis,
          treatment: treatment,
          prediction: widget.prediction,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('No treatment selected or notes provided.'),
              content: const Text('Please enter a prescription.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        if (state is DiagnosisUpdated) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Diagnosis'),
        ),
        body: BlocBuilder<DiagnosisBloc, DiagnosisState>(
          builder: (context, state) {
            return state is DiagnosisLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          toTitleCase(widget.prediction.disease.name),
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.prediction.disease.treatments.isNotEmpty)
                  Column(
                    children: widget.prediction.disease.treatments.map((
                        treatment) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Radio<Treatment>(
                            value: treatment,
                            groupValue: selectedTreatment,
                            onChanged: (value) {
                              setState(() {
                                selectedTreatment = value;
                              });
                            },
                          ),
                          title: Text(treatment.title),
                          subtitle: Text(treatment.description),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: treatmentController,
                    onChanged: (value) {
                      setState(() {
                        isTreatmentFilled = value.isNotEmpty;
                      });
                    },
                    //maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write some notes for the patient.',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: handleReferTreatment,
                      child: const Text('Refer Treatment'),
                    ),
                    ElevatedButton(
                      onPressed: handleSubmitTreatment,
                      child: const Text('Submit Treatment'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
