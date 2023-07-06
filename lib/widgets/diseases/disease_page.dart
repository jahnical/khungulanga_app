import 'package:flutter/material.dart';
import 'package:khungulanga_app/models/disease.dart';
import 'package:khungulanga_app/util/common.dart';

/// A page that displays detailed information about a specific disease.
class DiseaseDetailPage extends StatelessWidget {
  final Disease disease;

  const DiseaseDetailPage({Key? key, required this.disease}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(disease.name.toUpperCase()),
      ),
      body: _buildBody(),
    );
  }

  /// Builds the body of the disease detail page.
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue,
                ),
                SizedBox(width: 8.0),
                Text(
                  toTitleCase(disease.name),
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),
          Text(
            'Description:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            disease.description,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 24.0),
          Row(
            children: [
              Icon(
                Icons.priority_high,
                color: Colors.red,
              ),
              SizedBox(width: 8.0),
              Text(
                'Severity: ${disease.severity}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.0),
          Text(
            'Common Treatments:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Text(
                'Note: Use the doctor notes if available. The treatments listed here are for informational purposes only. It is advised to consult a qualified dermatologist for confirmation and personalized treatment recommendations.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ListView.builder(
            shrinkWrap: true,
            itemCount: disease.treatments.length,
            itemBuilder: (context, index) {
              final treatment = disease.treatments[index];
              return Card(
                elevation: 2.0,
                child: ListTile(
                  leading: Icon(
                    Icons.medical_services,
                    color: Colors.blue,
                  ),
                  title: Text(
                    treatment.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(treatment.description),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
