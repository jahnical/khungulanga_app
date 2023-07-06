import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/auth_bloc/auth_bloc.dart';
import 'package:khungulanga_app/blocs/login_bloc/login_bloc.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/auth/login/login_form.dart';

/// A page that displays a login form.
class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  const LoginPage({Key? key, required this.userRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginForm(),
      ),
    );
  }
}