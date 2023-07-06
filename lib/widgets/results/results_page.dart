import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnoses_list.dart';
import 'package:khungulanga_app/widgets/refreshable_widget.dart';
import '../../repositories/notifications_repository.dart';

/// A page that displays the results of the diagnosis.
class ResultsPage extends RefreshableWidget {
  ResultsPage({Key? key}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends RefreshableWidgetState<ResultsPage> {
  late DiagnosisBloc _diagnosisBloc;

  @override
  void initState() {
    super.initState();
    _diagnosisBloc = BlocProvider.of<DiagnosisBloc>(context);
    _diagnosisBloc.add(FetchDiagnoses()); // Initial load of diagnoses

    final notRepo = RepositoryProvider.of<NotificationRepository>(context);

    // Listen for notification updates and fetch diagnoses if there are unread diagnosis feedback
    NotificationRepository.notificationsStream?.listen((event) {
      if (notRepo.hasUnreadDiagnosisFeedback()) _diagnosisBloc.add(FetchDiagnoses());
    });
  }

  /// Triggers a refresh of the diagnoses.
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
              return Center(
                child: Text(
                  'No results available.',
                  style: Theme.of(context).textTheme.headline6?.apply(color: Theme.of(context).primaryColor),
                ),
              );
            } else {
              return DiagnosesList(diagnoses: state.diagnoses, isHistory: false);
            }
          } else if (state is DiagnosisError) {
            return Center(
              child: Text(
                'Error occurred while loading diagnoses.',
                style: Theme.of(context).textTheme.headline6?.apply(color: Theme.of(context).errorColor),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
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
