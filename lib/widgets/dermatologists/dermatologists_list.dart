import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/dermatologists_bloc/dermatologists_bloc.dart';
import 'package:khungulanga_app/models/dermatologist.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/widgets/appointment/appointment_chat_page.dart';
import 'package:khungulanga_app/widgets/profile/derm_profile.dart';
import 'package:khungulanga_app/widgets/slots/book_slot.dart';
import 'package:khungulanga_app/widgets/slots/derm_slots.dart';

import '../../repositories/diagnosis_repository.dart';

class DermatologistList extends StatefulWidget {
  final List<double> userLocation;
  final Diagnosis? diagnosis;

  DermatologistList({
    required this.userLocation,
    this.diagnosis,
  });

  @override
  _DermatologistListState createState() => _DermatologistListState();
}

class _DermatologistListState extends State<DermatologistList> {
  bool _isUpdating = false;

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () =>
                context.read<DermatologistsBloc>().add(LoadDermatologistsEvent()),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(BuildContext context, Dermatologist dermatologist) {
    // Code to navigate to appointment chat screen
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return BookSlotPage(
        dermatologist: dermatologist,
        diagnosis: widget.diagnosis,
      );
    }));
  }

  void _viewDetails(BuildContext context, Dermatologist dermatologist) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return DermatologistProfilePage(
        dermatologist: dermatologist,
        diagnosis: widget.diagnosis,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DermatologistsBloc, DermatologistsState>(
      builder: (context, state) {
        if (state is DermatologistsLoadingState) {
          return _buildLoadingIndicator();
        } else if (state is DermatologistsLoadedState) {
          return _buildDermatologistsList(state.dermatologists, context);
        } else if (state is DermatologistsErrorState) {
          return _buildError(context, state.errorMessage);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildDermatologistsList(
      List<Dermatologist> dermatologists, BuildContext context) {
    return ListView.builder(
      itemCount: dermatologists.length,
      itemBuilder: (BuildContext context, int index) {
        final dermatologist = dermatologists[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: Text(
                '\$${dermatologist.hourlyRate}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              title: Text(
                '${dermatologist.user.firstName} ${dermatologist.user.lastName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.0),
                  Text(dermatologist.specialization),
                  SizedBox(height: 4.0),
                  Text(dermatologist.clinic.name),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  widget.diagnosis != null &&
                      widget.diagnosis?.dermatologist == null &&
                      dermatologist.hourlyRate < 1
                      ? Icons.send
                      : Icons.book,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () =>
                widget.diagnosis != null &&
                    widget.diagnosis?.dermatologist == null &&
                    dermatologist.hourlyRate < 1
                    ? _sendResults(context, dermatologist)
                    : _bookAppointment(context, dermatologist),
              ),
              onTap: () => _viewDetails(context, dermatologist),
            ),
          ),
        );
      },
    );
  }

  _sendResults(BuildContext context, Dermatologist dermatologist) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String additionalInfo = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Confirm Sending Results'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Please provide any additional information concerning your problem:'),
                  SizedBox(height: 16.0),
                  TextField(
                    onChanged: (value) {
                      additionalInfo = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Additional Information',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isUpdating = true;
                    });

                    await _updateDiagnosis(context, dermatologist, additionalInfo);
                    Navigator.of(context).pop();
                  },
                  child: _isUpdating
                      ? CircularProgressIndicator()
                      : Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateDiagnosis(
      BuildContext context, Dermatologist dermatologist, String additionalInfo) async {
    setState(() {
      _isUpdating = true;
    });

    final repo = RepositoryProvider.of<DiagnosisRepository>(context);
    try {
      widget.diagnosis!.dermatologist = dermatologist;
      widget.diagnosis!.extraDermInfo = additionalInfo;
      await repo.updateDiagnosis(widget.diagnosis!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Results sent successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      widget.diagnosis!.dermatologist = null;
      widget.diagnosis!.extraDermInfo = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send results'),
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
}
