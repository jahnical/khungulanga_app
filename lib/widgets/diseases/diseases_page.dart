import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/disease_bloc/disease_bloc.dart';
import 'package:khungulanga_app/models/disease.dart';
import 'package:khungulanga_app/repositories/disease_repository.dart';
import 'package:khungulanga_app/util/common.dart';
import 'package:khungulanga_app/widgets/diseases/disease_page.dart';

class DiseasesPage extends StatelessWidget {
  const DiseasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiseaseBloc(RepositoryProvider.of<DiseaseRepository>(context))..add(LoadDiseasesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supported Diseases'),
        ),
        body: BlocBuilder<DiseaseBloc, DiseaseState>(
          builder: (context, state) {
            if (state is DiseasesLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DiseasesLoadedState) {
              return _buildDiseasesList(state.diseases);
            } else if (state is DiseasesErrorState) {
              return _buildErrorIndicator(context);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildDiseasesList(List<Disease> diseases) {
    return ListView.builder(
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        final disease = diseases[index];
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: ListTile(
            leading: const Icon(Icons.local_hospital, color: Colors.blue),
            title: Text(toTitleCase(disease.name)),
            subtitle: Text(
              'Severity: ${disease.severity}',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DiseaseDetailPage(disease: disease),
              ));
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorIndicator(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Failed to load diseases. Please check your internet connection and try again.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            BlocProvider.of<DiseaseBloc>(context).add(LoadDiseasesEvent());
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}