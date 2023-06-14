import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/util/common.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/widgets/diagnosis/diagnosis_page.dart';

class DiagnosesList extends StatelessWidget {
  final List<Diagnosis> diagnoses;

  const DiagnosesList({Key? key, required this.diagnoses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiagnosisBloc, DiagnosisState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: diagnoses.length,
          itemBuilder: (context, index) {
            final diagnosis = diagnoses[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DiagnosisPage(diagnosis: diagnosis),
                ));
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
                      title: Text(
                        toTitleCase(diagnosis.predictions[0].disease.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        diagnosis.date.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        '${(diagnosis.predictions[0].probability * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
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
        );
      },
    );
  }
}
