import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/dermatologists_bloc/dermatologists_bloc.dart';
import 'package:khungulanga_app/models/dermatologist.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/widgets/appointment/appointment_chat_page.dart';
import 'package:khungulanga_app/widgets/profile/derm_profile.dart';
import 'package:khungulanga_app/widgets/refreshable_widget.dart';
import 'package:khungulanga_app/widgets/slots/book_slot.dart';
import 'package:khungulanga_app/widgets/slots/derm_slots.dart';

import '../../repositories/diagnosis_repository.dart';

class DermatologistList extends RefreshableWidget {
  final List<double> userLocation;
  final Diagnosis? diagnosis;

  DermatologistList({
    required this.userLocation,
    this.diagnosis,
  });

  @override
  _DermatologistListState createState() => _DermatologistListState();
}

class _DermatologistListState extends RefreshableWidgetState<DermatologistList> {
  bool _isUpdating = false;
  FilterType filterType = FilterType.All;
  List<Dermatologist> filteredDermatologists = [];

  @override
  void initState() {
    super.initState();
    filteredDermatologists = [];
    filterType = widget.diagnosis != null? FilterType.Free : FilterType.All;

    if (BlocProvider.of<DermatologistsBloc>(context).state is DermatologistsLoadedState) {
      _applyFilter(filterType, (BlocProvider.of<DermatologistsBloc>(context).state as DermatologistsLoadedState).dermatologists);
    }
  }

  void _applyFilter(FilterType type, List<Dermatologist> dermatologists) {
    setState(() {
      filterType = type;
      if (type == FilterType.All) {
        filteredDermatologists = dermatologists;
      } else {
        filteredDermatologists = dermatologists
            .where((dermatologist) => type == FilterType.Free ? dermatologist.hourlyRate <= 0 : dermatologist.hourlyRate > 0)
            .toList();
      }
    });
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(errorMessage),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () =>
                context.read<DermatologistsBloc>().add(LoadDermatologistsEvent()),
            child: const Text('Retry'),
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
    return BlocListener<DermatologistsBloc, DermatologistsState>(
        listener: (context, state) {
          if (state is DermatologistsLoadedState) _applyFilter(filterType, state.dermatologists);
        },
        child: RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: BlocBuilder<DermatologistsBloc, DermatologistsState>(
            builder: (context, state) {
              if (state is DermatologistsLoadingState) {
                return _buildLoadingIndicator();
              } else if (state is DermatologistsLoadedState) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                          label: Text('All'),
                          selected: filterType == FilterType.All,
                          onSelected: (selected) => _applyFilter(FilterType.All, state.dermatologists),
                          selectedColor: Colors.lightBlueAccent,
                        ),
                        SizedBox(width: 16),
                        FilterChip(
                          label: Text('Public'),
                          selected: filterType == FilterType.Free,
                          onSelected: (selected) => _applyFilter(FilterType.Free, state.dermatologists),
                          selectedColor: Colors.lightBlueAccent,
                        ),
                        SizedBox(width: 16),
                        FilterChip(
                          label: Text('Private'),
                          selected: filterType == FilterType.Paid,
                          onSelected: (selected) => _applyFilter(FilterType.Paid, state.dermatologists),
                          selectedColor: Colors.lightBlueAccent,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildDermatologistsList(filteredDermatologists, context),
                  ],
                );
              } else if (state is DermatologistsErrorState) {
                return _buildError(context, state.errorMessage);
              } else {
                return Container();
              }
            },
          ),
    ),
);
  }

  Widget _buildDermatologistsList(
      List<Dermatologist> dermatologists, BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
                'MWK ${dermatologist.hourlyRate}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
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
                onPressed: () => widget.diagnosis != null &&
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
                  Text(
                    'Please provide any additional information concerning your problem:\n(You can as well book an appointment)',
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    onChanged: (value) {
                      additionalInfo = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Additional Information',
                    ),
                    maxLines: null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                IconButton(
                  onPressed: () => _bookAppointment(context, dermatologist),
                  icon: Icon(Icons.book, color: Theme.of(context).primaryColor),
                ),
                IconButton(
                  onPressed: () async {
                    setState(() {
                      _isUpdating = true;
                    });

                    await _updateDiagnosis(context, dermatologist, additionalInfo);
                    Navigator.of(context).pop();
                  },
                  icon: _isUpdating
                      ? CircularProgressIndicator()
                      : Icon(Icons.send, color: Theme.of(context).primaryColor),
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
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      widget.diagnosis!.dermatologist = null;
      widget.diagnosis!.extraDermInfo = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send results'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  refresh() {
    context.read<DermatologistsBloc>().add(LoadDermatologistsEvent());
  }
}

enum FilterType {
  All,
  Free,
  Paid,
}