import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/auth_bloc/auth_bloc.dart';
import 'package:khungulanga_app/blocs/register_bloc/register_bloc.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/auth/register/register_form.dart';

import 'derm_register_form.dart';

class RegisterDermPage extends StatelessWidget {
  final UserRepository userRepository;

  const RegisterDermPage({Key? key, required this.userRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: BlocProvider(
        create: (context) {
          return RegisterBloc(
              authenticationBloc: BlocProvider.of<AuthBloc>(context),
              userRepository: userRepository,
              context: context);
        },
        child: RegisterDermForm(),
      ),
    );
  }
}