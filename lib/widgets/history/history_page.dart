import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/repositories/notifications_repository.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnoses_list.dart';
import 'package:khungulanga_app/widgets/refreshable_widget.dart';

class HistoryPage extends RefreshableWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends RefreshableWidgetState<HistoryPage> {
  late DiagnosisBloc _diagnosisBloc;

  @override
  void initState() {
    super.initState();
    _diagnosisBloc = BlocProvider.of<DiagnosisBloc>(context);
    _diagnosisBloc.add(FetchDiagnoses()); // Initial load of diagnoses

    final notRepo = RepositoryProvider.of<NotificationRepository>(context);
    NotificationRepository.notificationsStream?.listen((event) {
      if (notRepo.hasUnreadDiagnosisFeedback()) _diagnosisBloc.add(FetchDiagnoses());
    });
  }

  Future<void> _refreshDiagnoses() async {
    _diagnosisBloc.add(FetchDiagnoses()); // Trigger reload of diagnoses
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDiagnoses, // Define the refresh callback
      child: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          if (state is DiagnosisLoaded) {
            if (state.diagnoses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No diagnoses saved!',
                      style: Theme.of(context).textTheme.headlineLarge?.apply(color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Our app uses machine learning to diagnose skin diseases with high accuracy. Click the scan button to check your skin.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return DiagnosesList(diagnoses: state.diagnoses);
            }
          } else if (state is DiagnosisLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DiagnosisError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'An error occurred while loading the diagnoses.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => BlocProvider.of<DiagnosisBloc>(context).add(FetchDiagnoses()),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return DiagnosesList(diagnoses: state.diagnoses);
          }
        },
      ),
    );
  }

  @override
  refresh() {
    _refreshDiagnoses();
  }
}
