import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/widgets/dermatologists/dermatologists_page.dart';
import 'package:khungulanga_app/widgets/diseases/disease_page.dart';
import '../../blocs/diagnosis_bloc/diagnosis_bloc.dart';

class DiagnosisPage extends StatelessWidget {
  final Diagnosis diagnosis;
  final bool fromAppointment;

  const DiagnosisPage({Key? key, required this.diagnosis, this.fromAppointment = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        log(state.toString());
        if (state is DiagnosisDeletingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred while deleting the diagnosis.'),
            ),
          );
        } else if (state is DiagnosisDeleted) {
          Navigator.of(context).pop();
        } else if (state is ConfirmingDiagnosisDelete) {
          _confirmDelete(state.diagnosis, context, context.read<DiagnosisBloc>());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diagnosis Results'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                context.read<DiagnosisBloc>().add(DeleteDiagnosisPressed(diagnosis));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
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
                        BASE_URL + diagnosis.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    diagnosis.predictions[0].disease.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${(diagnosis.predictions[0].probability * 100).toInt()}% Probability',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      diagnosis.predictions[0].disease.description,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(
                      Icons.medical_services,
                      color: Colors.blue,
                    ),
                    title: Text(
                      diagnosis.predictions[0].disease.treatments[0].title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(diagnosis.predictions[0].disease.treatments[0].description),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ViewMoreButton(onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DiseaseDetailPage(
                          disease: diagnosis.predictions[0].disease,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 16),
                ],
              ),
              SizedBox(height: 24),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Text(
                        'Note: This should not be considered a final diagnosis or used in place of a dermatologist.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  fromAppointment ? const SizedBox() : ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DermatologistsPage(
                            diagnosis: diagnosis,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.phone),
                    label: Text('Contact a Dermatologist'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(
                thickness: 2.0,
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.help_outline,
                            size: 32,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Other possible diagnoses:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: diagnosis.predictions.length - 1,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            SizedBox(height: 8),
                            Card(
                              elevation: 2.0,
                              child: ListTile(
                                leading: Icon(
                                  Icons.local_hospital,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  diagnosis.predictions[index + 1].disease.name.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  _getEllipsizedDescription(
                                      diagnosis.predictions[index + 1].disease.description),
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Text(
                                    '${(diagnosis.predictions[index + 1].probability * 100).toInt()}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            if (index < diagnosis.predictions.length - 2)
                              Divider(
                                color: Colors.grey[300],
                                height: 1,
                                thickness: 1,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Diagnosis diagnosis, BuildContext context, DiagnosisBloc bloc) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diagnosis'),
        content: const Text('Are you sure you want to delete this diagnosis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).errorColor,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed) {
      bloc.add(DeleteDiagnosis(diagnosis));
    }
  }

  String _getEllipsizedDescription(String description) {
    if (description.length > 100) {
      return description.substring(0, 100) + '...';
    } else {
      return description;
    }
  }
}

class ViewMoreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ViewMoreButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.arrow_forward),
      label: Text('View More'),
      style: TextButton.styleFrom(
        primary: Colors.lightBlueAccent,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
