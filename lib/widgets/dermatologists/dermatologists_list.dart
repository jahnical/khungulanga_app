import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/dermatologists_bloc/dermatologists_bloc.dart';
import 'package:khungulanga_app/models/dermatologist.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/widgets/appointment/appointment_chat_page.dart';
import 'package:khungulanga_app/widgets/profile/derm_profile.dart';
import 'package:khungulanga_app/widgets/slots/book_slot.dart';
import 'package:khungulanga_app/widgets/slots/derm_slots.dart';

class DermatologistList extends StatelessWidget {
  final List<double> userLocation;
  final Diagnosis? diagnosis;

  DermatologistList({
    required this.userLocation,
    this.diagnosis,
  });

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
              onPressed: () => context.read<DermatologistsBloc>().add(LoadDermatologistsEvent()),
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
        diagnosis: diagnosis,
      );
    }));
  }

  void _viewDetails(BuildContext context, Dermatologist dermatologist) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return DermatologistProfilePage(dermatologist: dermatologist, diagnosis: diagnosis,);
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

  Widget _buildDermatologistsList(List<Dermatologist> dermatologists, BuildContext context) {
    return ListView.builder(
      itemCount: dermatologists.length,
      itemBuilder: (BuildContext context, int index) {
        final dermatologist = dermatologists[index];
        return Column(
          children: [
            SizedBox(height: 8.0),
            ListTile(
              leading: Text('\$${dermatologist.hourlyRate}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              title: Text(
                '${dermatologist.user.firstName} ${dermatologist.user.lastName}',
                style: const TextStyle(
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
                icon: Icon(Icons.book, color: Theme.of(context).primaryColor),
                onPressed: () => _bookAppointment(context, dermatologist),
              ),
              onTap: () => _viewDetails(context, dermatologist),
            ),
            SizedBox(height: 8.0),
            Divider(height: 1.0, thickness: 1.0),
          ],
        );
      },
    );
  }
}