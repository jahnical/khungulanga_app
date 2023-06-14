import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/login_bloc/login_bloc.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

import '../register/derm_register_page.dart';
import '../register/register_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _onRegisterButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage(userRepository: UserRepository(),)),
    );
  }

  _onDermRegisterButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterDermPage(userRepository: UserRepository(),)),
    );
  }

  _onLoginButtonPressed() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFaliure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${state.error}'),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Center(
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Email address', icon: Icon(Icons.person)),
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          //Check if email is valid using email regex
                          else if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value) ) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'password', icon: Icon(Icons.security)),
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
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
                              onPressed: state is! LoginLoading
                                  ? _onLoginButtonPressed
                                  : null,
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: state is LoginLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24.0,
                                ),
                              )
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextButton(
                        onPressed: _onRegisterButtonPressed,
                        child: const Text('Register As Patient'),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextButton(
                        onPressed: _onDermRegisterButtonPressed,
                        child: const Text('Register As Dermatologist'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}