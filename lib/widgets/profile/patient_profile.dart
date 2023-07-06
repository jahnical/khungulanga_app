import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/patient.dart';
import 'package:khungulanga_app/repositories/patient_repository.dart';

/// A page that displays and allows editing of the patient's profile.
class PatientProfilePage extends StatefulWidget {
  final Patient patient;

  PatientProfilePage({required this.patient});

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool _isEditing = false;
  bool _fieldsUpdated = false;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.patient.user?.firstName ?? '';
    _lastNameController.text = widget.patient.user?.lastName ?? '';
    _selectedDate = widget.patient.dob;
    _selectedGender = widget.patient.gender;
    _emailController.text = widget.patient.user?.email ?? '';
  }

  /// Toggles the edit mode of the profile.
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      _fieldsUpdated = false;
    });
  }

  /// Checks if any fields have been updated and updates the state accordingly.
  void _checkFieldsUpdated() {
    if (!_fieldsUpdated) {
      if (_firstNameController.text != widget.patient.user?.firstName ||
          _lastNameController.text != widget.patient.user?.lastName ||
          _selectedDate != widget.patient.dob ||
          _selectedGender != widget.patient.gender ||
          _emailController.text != widget.patient.user?.email) {
        setState(() {
          _fieldsUpdated = true;
        });
      }
    }
  }

  /// Saves the changes made to the profile.
  Future<void> _saveChanges() async {
    if (_fieldsUpdated) {
      // Show confirmation dialog
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

      if (confirmed != null && confirmed) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16.0),
                    Text('Updating profile...'),
                  ],
                ),
              ),
            );
          },
        );

        // Update the patient profile
        try {
          Patient updatedPatient = widget.patient;
          updatedPatient.user?.firstName = _firstNameController.text;
          updatedPatient.user?.lastName = _lastNameController.text;
          updatedPatient.user?.email = _emailController.text;
          updatedPatient.gender = _selectedGender!;
          updatedPatient.dob = _selectedDate!;
          await RepositoryProvider.of<PatientRepository>(context).updatePatient(updatedPatient);

          // Update the current patient object
          setState(() {
            widget.patient.user?.firstName = _firstNameController.text;
            widget.patient.user?.lastName = _lastNameController.text;
            widget.patient.user?.email = _emailController.text;
            widget.patient.gender = _selectedGender!;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ));
        } catch (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update profile: $error'),
            backgroundColor: Colors.red,
          ));
        }

        // Hide loading
        Navigator.pop(context);
      }
    }

    // Reset the editing state
    _toggleEdit();
  }

  /// Shows a date picker dialog to select the date of birth.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _checkFieldsUpdated();
      });
    }
  }

  /// Selects the gender value.
  void _selectGender(String gender) {
    if (_selectedGender != gender) {
      setState(() {
        _selectedGender = gender;
        _checkFieldsUpdated();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: _toggleEdit,
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
          ),
          if (_isEditing && _fieldsUpdated)
            IconButton(
              onPressed: _saveChanges,
              icon: Icon(Icons.save),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            onChanged: _checkFieldsUpdated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _isEditing ? () => _selectDate(context) : null,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : ''),
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your date ofbirth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text('Male'),
                        value: 'Male',
                        groupValue: _selectedGender,
                        onChanged: _isEditing ? (value) => _selectGender(value.toString()) : null,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text('Female'),
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: _isEditing ? (value) => _selectGender(value.toString()) : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
