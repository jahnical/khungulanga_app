import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/models/notification.dart';
import 'package:khungulanga_app/repositories/notifications_repository.dart';
import 'package:khungulanga_app/util/common.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnosis_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'derm_diagnosis_page.dart';

class DiagnosesList extends StatefulWidget {
  final List<Diagnosis> diagnoses;
  final bool isHistory;

  DiagnosesList({Key? key, required this.diagnoses, this.isHistory = true}) : super(key: key);

  @override
  _DiagnosesListState createState() => _DiagnosesListState();
}

class _DiagnosesListState extends State<DiagnosesList> {
  List<Diagnosis> filteredDiagnoses = [];
  FilterType filterType = FilterType.All;

  @override
  void initState() {
    super.initState();
    filteredDiagnoses = widget.diagnoses;
    //if (!widget.isHistory) filterType = FilterType.NotResponded;
  }

  /// Apply the selected filter type to the diagnoses list.
  void _applyFilter(FilterType type) {
    setState(() {
      filterType = type;
      if (type == FilterType.All) {
        filteredDiagnoses = widget.diagnoses;
      } else {
        filteredDiagnoses = widget.diagnoses
            .where((diagnosis) => (type == FilterType.Responded) ? diagnosis.action != "Pending" : diagnosis.action == "Pending")
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    filteredDiagnoses.sort((a, b) => b.date.compareTo(a.date));
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilterChip(
              label: Text('All'),
              selected: filterType == FilterType.All,
              onSelected: (value) {
                _applyFilter(FilterType.All);
              },
              selectedColor: Colors.lightBlueAccent,
            ),
            SizedBox(width: 16),
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationRepository.notificationsStream,
              builder: (context, snapshot) {
                return FilterChip(
                  avatar: !widget.isHistory && RepositoryProvider.of<NotificationRepository>(context).hasUnreadDiagnosisFeedback()
                      ? Icon(Icons.circle, color: Colors.purpleAccent, size: 16,)
                      : null,
                  label: Text(widget.isHistory ? 'Without Response' : "Pending"),
                  selected: filterType == FilterType.NotResponded,
                  onSelected: (value) {
                    _applyFilter(FilterType.NotResponded);
                  },
                  selectedColor: Colors.lightBlueAccent,
                );
              },
            ),
            SizedBox(width: 16),
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationRepository.notificationsStream,
              builder: (context, snapshot) {
                return FilterChip(
                  avatar: widget.isHistory && RepositoryProvider.of<NotificationRepository>(context).hasUnreadDiagnosisFeedback()
                      ? Icon(Icons.circle, color: Colors.purpleAccent, size: 16,)
                      : null,
                  label: Text(widget.isHistory ?
                      'With Response' : 'Responded'),
                  selected: filterType == FilterType.Responded,
                  onSelected: (value) {
                    _applyFilter(FilterType.Responded);
                  },
                  selectedColor: Colors.lightBlueAccent,
                );
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredDiagnoses.length,
            itemBuilder: (context, index) {
              final diagnosis = filteredDiagnoses[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => widget.isHistory
                          ? DiagnosisPage(diagnosis: diagnosis)
                          : DermDiagnosisPage(diagnosis: diagnosis),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0.0, 1.0),
                                blurRadius: 2.0,
                              ),
                            ],
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              BASE_URL + diagnosis.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              widget.isHistory
                                  ? toTitleCase(diagnosis.predictions.isNotEmpty
                                  ? (diagnosis.approved? diagnosis.predictions.firstWhere((element) => element.approved) : diagnosis.predictions[0]).disease.name
                                  : "No Disease")
                                  : 'Results From: ${diagnosis.patient.user?.firstName} ${diagnosis.patient.user?.lastName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 4),
                            if (widget.isHistory)
                              Icon(
                                !diagnosis.approved
                                    ? diagnosis.action == 'Referral'
                                    ? Icons.cancel
                                    : Icons.access_time_filled
                                    : Icons.check_circle,
                                color: !diagnosis.approved
                                    ? diagnosis.action == 'Referral'
                                    ? Colors.red
                                    : Colors.grey
                                    : Colors.green,
                                size: 16,
                              )
                          ],
                        ),
                        subtitle: Text(
                          timeago.format(diagnosis.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: !diagnosis.approved ? Text(
                          diagnosis.predictions.isNotEmpty
                              ? '${(diagnosis.predictions[0].probability * 100).toInt()}%'
                              : 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ) : null,
                      ),
                      const Divider(
                        height: 8,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Represents the filter type for diagnoses list.
enum FilterType {
  All,
  Responded,
  NotResponded,
}
