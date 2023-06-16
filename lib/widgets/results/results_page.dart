import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnoses_list.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiagnosisBloc, DiagnosisState>(
      builder: (context, state) {
        if (state is DiagnosisLoaded) {
          if (state.diagnoses.isEmpty) {
            return Center(
              child: Text(
                'No diagnoses available.',
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
    );
  }
}
