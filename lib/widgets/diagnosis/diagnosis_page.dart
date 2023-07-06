import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/models/prediction.dart';
import 'package:khungulanga_app/widgets/dermatologists/dermatologists_page.dart';
import 'package:khungulanga_app/widgets/diseases/disease_page.dart';
import '../../blocs/diagnosis_bloc/diagnosis_bloc.dart';

/// A page for viewing a diagnosis.
class DiagnosisPage extends StatefulWidget {
  final Diagnosis diagnosis;
  final bool fromAppointment;

  const DiagnosisPage({Key? key, required this.diagnosis, this.fromAppointment = false})
      : super(key: key);

  @override
  _DiagnosisPageState createState() => _DiagnosisPageState(this.diagnosis, this.fromAppointment);
}

/// The state for the DiagnosisPage.
class _DiagnosisPageState extends State<DiagnosisPage> {
  bool _isDeleting = false;
  final Diagnosis diagnosis;
  final bool fromAppointment;

  _DiagnosisPageState(this.diagnosis, this.fromAppointment);


  @override
  Widget build(BuildContext context) {
    return BlocListener<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        log(state.toString());
        if (state is DiagnosisDeletingError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred while deleting the diagnosis.'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is DiagnosisDeleted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else if (state is ConfirmingDiagnosisDelete) {
          _confirmDelete(state.diagnosis, context, context.read<DiagnosisBloc>());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Results${!diagnosis.approved? diagnosis.action == 'Referral' ? ' (Incorrect)' : ' (Not Approved)' : ' (Approved)'}'),
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
                  if (diagnosis.predictions.isNotEmpty)
                    _mainPrediction(diagnosis.approved? diagnosis.predictions.firstWhere((element) => element.approved) : diagnosis.predictions[0], context)
                  else
                    Center(
                      widthFactor: .8,
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          !diagnosis.approved? 'Your skin condition could not be diagnosed, no lesion has been identified.\n\nYou can contact a dermatologist for further assistance.'
                          : '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              fontFamily: 'OpenSans',
                            ),
                        ),
                      ),
                    ),
                ],
              ),
              //SizedBox(height: 8),


              SizedBox(height: 4),
              Divider(
                thickness: 2.0,
                height: 16.0,
              ),
              if (!diagnosis.approved) _infoForNotApprove(),
              fromAppointment ? const SizedBox() : diagnosis.dermatologist == null || diagnosis.action != "Pending"? ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DermatologistsPage(
                        diagnosis: diagnosis,
                      ),
                    ),
                  );
                },
                icon: Icon(diagnosis.dermatologist == null? Icons.phone : Icons.book),
                label: Text(diagnosis.dermatologist == null ? 'Contact a Dermatologist' : 'Book An Appointment'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ): DiagnosisAction(diagnosis),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows dialog to confirm deletion of a diagnosis.
  void _confirmDelete(Diagnosis diagnosis, BuildContext context, DiagnosisBloc bloc) async {
    setState(() {
      _isDeleting = false;
    });
    final confirmed = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Diagnosis'),
            content: const Text('Are you sure you want to delete this diagnosis?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              _isDeleting? const CircularProgressIndicator() : TextButton(
                onPressed: () {
                  setState(() {
                    _isDeleting = true;
                  });
                  bloc.add(DeleteDiagnosis(diagnosis));
                },
                style: TextButton.styleFrom(
                  primary: Theme.of(context).errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        }
      ),
    );

    if (confirmed != null && confirmed) {

    }
  }

  /// Returns an ellipsized version of the description.
  String _getEllipsizedDescription(String description) {
    if (description.length > 100) {
      return description.substring(0, 100) + '...';
    } else {
      return description;
    }
  }

  /// Shows the main prediction. Either the first approved prediction or the first prediction.
  _mainPrediction(Prediction prediction, BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Text(
          prediction.disease.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlueAccent,
          ),
        ),
        SizedBox(height: 8),
        if (!prediction.approved)
        Text(
          '${(prediction.probability * 100).toInt()}% Probability',
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
            prediction.disease.description,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 16.0),
        if (diagnosis.approved)
          Column(
            children: [
              if (prediction.treatmentId != null)
              ListTile(
                leading: Icon(
                  Icons.medical_services,
                  color: Colors.blue,
                ),
                title: Text(
                  "Treatment",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(prediction.disease.treatments.firstWhere((element) => element.id == prediction.treatmentId).description ?? "No Notes Provided"),
              ),
              SizedBox(height: 16.0),
              ListTile(
                leading: Icon(
                  Icons.medical_services,
                  color: Colors.blue,
                ),
                title: Text(
                  "Doctor Notes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(prediction.treatment ?? "No Notes Provided"),
              ),
            ],
          ),
      ],
    );
  }

  /// Shows the other possible predictions.
  _infoForNotApprove() {
    return Column(
      children: [
        if (diagnosis.predictions.length > 1)
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
                child: const Text(
                  'Disclaimer: The information provided is for informational purposes only and should not be considered a final diagnosis or a replacement for professional dermatological advice. It is advised to consult a qualified dermatologist for confirmation and personalized treatment recommendations.',
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
          ],
        ),

      ],
    );
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

/// Shows the treatment recommendation and doctor notes.
class DiagnosisAction extends StatelessWidget {
  final Diagnosis diagnosis;

  DiagnosisAction(this.diagnosis);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatment Recommendation',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          if (diagnosis.action == 'treatment')
            Text(
              diagnosis.predictions.firstWhere((element) => element.approved).treatment ?? "No Treatment",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          if (diagnosis.action == 'Pending')
            Text(
              'Pending Feedback',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          if (diagnosis.action != 'Pending')
            Text(
              'No Action Recommended',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
        ],
      ),
    );
  }
}

