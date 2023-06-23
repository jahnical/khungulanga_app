import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/blocs/register_bloc/register_bloc.dart';
import 'package:khungulanga_app/models/dermatologist.dart';
import 'package:khungulanga_app/repositories/clinic_repository.dart';
import 'package:khungulanga_app/repositories/dermatologist_repository.dart';

import '../../../models/clinic.dart';
import '../../models/diagnosis.dart';
import '../../repositories/user_repository.dart';
import '../slots/book_slot.dart';

class DermatologistProfilePage extends StatefulWidget {
  final Dermatologist dermatologist;
  final Diagnosis? diagnosis;

  DermatologistProfilePage({required this.dermatologist, this.diagnosis});

  @override
  State<DermatologistProfilePage> createState() =>
      _DermatologistProfilePageState();
}

class _DermatologistProfilePageState extends State<DermatologistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  Clinic? _selectedClinic;
  final _hourlyRateController = TextEditingController();
  bool _isEditing = false;
  bool _fieldsUpdated = false;
  bool _isLoading = false;
  List<Clinic> clinics = [];

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.dermatologist.phoneNumber;
    _emailController.text = widget.dermatologist.email;
    _selectedClinic = widget.dermatologist.clinic;
    _hourlyRateController.text = widget.dermatologist.hourlyRate.toString();

    _loadClinics();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _checkFieldsUpdated() {
    if (_phoneNumberController.text != widget.dermatologist.phoneNumber ||
        _emailController.text != widget.dermatologist.email ||
        _selectedClinic != widget.dermatologist.clinic ||
        double.parse(_hourlyRateController.text) !=
            widget.dermatologist.hourlyRate) {
      setState(() {
        _fieldsUpdated = true;
      });
    } else {
      setState(() {
        _fieldsUpdated = false;
      });
    }
  }

  void _saveChanges() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to update the profile?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (_formKey.currentState?.validate() == true && confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      final repo = RepositoryProvider.of<DermatologistRepository>(context);

      final updatedDermatologist = Dermatologist(
        id: widget.dermatologist.id,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        clinic: _selectedClinic!,
        hourlyRate: double.parse(_hourlyRateController.text),
        specialization: widget.dermatologist.specialization,
        user: widget.dermatologist.user,
        qualification: widget.dermatologist.qualification, slots: widget.dermatologist.slots,
      );

      try {
        await repo.updateDermatologist(updatedDermatologist);
        setState(() {
          _isLoading = false;
          _isEditing = false;
          _fieldsUpdated = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dermatologist Profile'),
        actions: [
          if (!isPatient(context))
            IconButton(
              onPressed: _toggleEditing,
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            ),
          if (_isEditing && _fieldsUpdated && !_isLoading)
            IconButton(
              onPressed: _saveChanges,
              icon: Icon(Icons.save),
            ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white,),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            onChanged: _checkFieldsUpdated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '${widget.dermatologist.user.firstName} ${widget.dermatologist.user.lastName}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  widget.dermatologist.specialization,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  enabled: _isEditing,
                  style: TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  enabled: _isEditing,
                  style: TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Clinic',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isEditing)
                  DropdownButtonFormField<Clinic>(
                    value: _selectedClinic,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedClinic = newValue;
                      });
                    },
                    items: clinics.map((clinic) {
                      return DropdownMenuItem<Clinic>(
                        value: clinic,
                        child: Text(clinic.name),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a clinic';
                      }
                      return null;
                    },
                  )
                else
                  Text(
                    _selectedClinic?.name ?? 'N/A',
                    style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 16),
                Text(
                  'Hourly Rate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _hourlyRateController,
                  enabled: _isEditing,
                  style: TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an hourly rate';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                if (isPatient(context))
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return BookSlotPage(
                          dermatologist: widget.dermatologist,
                          diagnosis: widget.diagnosis,
                        );
                      }));
                    },
                    child: Text('Book Appointment'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isPatient(BuildContext context) {
    return RepositoryProvider.of<UserRepository>(context).patient != null;
  }

  void _loadClinics() {
    final repo = RepositoryProvider.of<ClinicRepository>(context);
    repo.fetchClinics().then((clinics) {
      setState(() {
        this.clinics = clinics;
        _selectedClinic = clinics.firstWhere(
          (clinic) => clinic.id == widget.dermatologist.clinic.id,
        );
        _selectedClinic ??= clinics.first;
      });
    });
  }
}
