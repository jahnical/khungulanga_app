import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/blocs/register_bloc/register_bloc.dart';
import 'package:khungulanga_app/models/dermatologist.dart';
import 'package:khungulanga_app/repositories/clinic_repository.dart';

import '../../../models/clinic.dart';

class RegisterDermForm extends StatefulWidget {
  const RegisterDermForm({Key? key}) : super(key: key);

  @override
  State<RegisterDermForm> createState() =>
      _RegisterDermFormState();
}

class _RegisterDermFormState extends State<RegisterDermForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneNumber2Controller = TextEditingController();
  final _lastNameController = TextEditingController();
  String? selectedSpecialization;
  List specializations = Dermatologist.specializations;
  List<Clinic> clinics = [];
  Clinic? _selectedClinic;
  XFile? _pickedImage;

  _onLoginButtonPressed() {
    Navigator.pop(context);
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = XFile(pickedImage.path);
      });
    }
  }

  _onRegisterButtonPressed() {
    if (_formKey.currentState?.validate() == true && _pickedImage != null) {
      BlocProvider.of<RegisterBloc>(context).add(RegisterButtonPressedDerm(
        username: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        qualification: _pickedImage!.path,
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumber2Controller.text,
        clinic: _selectedClinic!,
        hourlyRate: double.parse(_hourlyRateController.text),
        specialization: selectedSpecialization!,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    ClinicRepository().fetchClinics().then((clinicList) {
      setState(() {
        clinics = clinicList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        icon: Icon(Icons.person),
                      ),
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        icon: Icon(Icons.person),
                      ),
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email),
                      ),
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your work email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        icon: Icon(Icons.phone),
                      ),
                      controller: _phoneNumber2Controller,
                    ),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Clinic',
                        icon: Icon(Icons.home),
                      ),
                      value: _selectedClinic,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedClinic = newValue;
                        });
                      },
                      items: clinics.map((clinic) {
                        return DropdownMenuItem(
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
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate',
                        icon: Icon(Icons.money),
                      ),
                      controller: _hourlyRateController,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your hourly rate';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        icon: Icon(Icons.home),
                      ),
                      value: selectedSpecialization,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSpecialization = newValue.toString();
                        });
                      },
                      items: specializations.map((sp) {
                        return DropdownMenuItem(
                          value: sp["id"],
                          child: Text(sp["name"]),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select specialization';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick Qualification Image'),
                        ),
                        if (_pickedImage != null)
                          Text(_pickedImage?.name ?? ""),
                      ],
                    ),
                    SizedBox(height: 16,),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        icon: Icon(Icons.security),
                      ),
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 8) {
                          return 'Please enter a password of at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        icon: Icon(Icons.security),
                      ),
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 8) {
                          return 'Please enter a password of at least 8 characters';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.width * 0.22,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: ElevatedButton(
                          onPressed: state is! RegisterLoading
                              ? _onRegisterButtonPressed
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          child: state is RegisterLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: _onLoginButtonPressed,
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
