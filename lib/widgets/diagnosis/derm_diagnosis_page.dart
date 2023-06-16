import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';

import '../../api_connection/endpoints.dart';
import '../../models/prediction.dart';

class DermDiagnosisPage extends StatefulWidget {
  final Diagnosis diagnosis;

  const DermDiagnosisPage({Key? key, required this.diagnosis}) : super(key: key);

  @override
  _DermDiagnosisPageState createState() => _DermDiagnosisPageState();
}

class _DermDiagnosisPageState extends State<DermDiagnosisPage> {
  int selectedPrediction = -1;
  TextEditingController treatmentController = TextEditingController();
  bool isTreatmentFilled = false;

  @override
  void dispose() {
    treatmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dermatologist Diagnosis'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0.0, 2.0),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.network(
                  BASE_URL + widget.diagnosis.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.diagnosis.extraDermInfo != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.diagnosis.extraDermInfo!,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            for (var i = 0; i < widget.diagnosis.predictions.length; i++)
              PredictionItem(
                prediction: widget.diagnosis.predictions[i],
                isSelected: selectedPrediction == i,
                onTap: () {
                  setState(() {
                    if (selectedPrediction == i) {
                      selectedPrediction = -1;
                    } else {
                      selectedPrediction = i;
                    }
                  });
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedPrediction != -1) {
                  final prediction =
                  widget.diagnosis.predictions[selectedPrediction];

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Submit Treatment'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: treatmentController,
                            onChanged: (value) {
                              setState(() {
                                isTreatmentFilled = value.isNotEmpty;
                              });
                            },
                            maxLines: 3,
                            decoration: const InputDecoration

                              (
                              hintText: 'Prescribe treatment...',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (isTreatmentFilled) {
                              // Submit treatment
                              final treatment = treatmentController.text;
                              context.read<DiagnosisBloc>().add(
                                SubmitTreatmentPressed(
                                    diagnosis: widget.diagnosis,
                                    treatment: treatment,
                                    prediction: prediction
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('No Treatment Entered'),
                                  content: const Text('Please enter the prescribed treatment.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: const Text('Submit Treatment'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Refer treatment
                            context.read<DiagnosisBloc>().add(
                              ReferTreatmentPressed(diagnosis: widget.diagnosis, prediction: prediction),
                            );
                          },
                          child: const Text('Refer Treatment'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('No Diagnosis Selected'),
                      content: const Text('Please select a diagnosis or indicate that none of them is correct.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Confirm Diagnosis'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<DiagnosisBloc>().add(RejectDiagnosisPressed(widget.diagnosis));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
              ),
              child: const Text('Reject Diagnosis'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PredictionItem extends StatelessWidget {
  final Prediction prediction;
  final bool isSelected;
  final VoidCallback onTap;

  const PredictionItem({
    Key? key,
    required this.prediction,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disease = prediction.disease;
    final descriptionLines = disease.description.split('\n');
    final maxLines = descriptionLines.length < 3 ? descriptionLines.length : 3;
    final trimmedDescription = descriptionLines.take(maxLines).join('\n');

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey[300],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize:

                      18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trimmedDescription,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(prediction.probability * 100).toStringAsFixed(2)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}