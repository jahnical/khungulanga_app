import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/auth_bloc/auth_bloc.dart';
import 'package:khungulanga_app/blocs/dermatologists_bloc/dermatologists_bloc.dart';
import 'package:khungulanga_app/blocs/diagnosis_bloc/diagnosis_bloc.dart';
import 'package:khungulanga_app/blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:khungulanga_app/repositories/diagnosis_repository.dart';
import 'package:khungulanga_app/repositories/disease_repository.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/auth/login/login_page.dart';
import 'package:khungulanga_app/widgets/common/loading_indicator.dart';
import 'package:khungulanga_app/widgets/home/derm_home_page.dart';
import 'package:khungulanga_app/widgets/home/home_page.dart';
import 'package:khungulanga_app/widgets/splash/splash_page.dart';
import 'api_connection/api_client.dart';
import 'widgets/scan/scan_page.dart';


class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}

main() {
  WidgetsFlutterBinding.ensureInitialized();
  initCamera();
  APIClient.setupCacheInterceptor();
  Bloc.observer = SimpleBlocObserver();
  final userRepository = UserRepository();

  runApp(
      BlocProvider<AuthBloc>(
        create: (context) {
          return AuthBloc(
              userRepository: userRepository
          )
            ..add(AppStarted());
        },
        child: App(userRepository: userRepository),
      )
  );
}

Future<void> initCamera() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  camera = firstCamera;
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  const App({Key? key, required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DiagnosisRepository()),
        RepositoryProvider(create: (context) => userRepository),
        RepositoryProvider(create: (context) => DiseaseRepository()),
        RepositoryProvider(create: (context) => AppointmentRepository()),
      ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (BuildContext context) => DermatologistsBloc(userLocation: [0.0, 0.0])
              ..add(LoadDermatologistsEvent())),
            BlocProvider(create: (context) => HomeNavigationBloc()),
            BlocProvider(create: (context) => DiagnosisBloc(repository: context.read<DiagnosisRepository>())
              ..add(FetchDiagnoses())),

          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                log(state.toString());
                if (state is AuthUninitialized) {
                  return const SplashPage();
                }
                if (state is AuthUnauthenticated) {
                  return LoginPage(userRepository: userRepository,);
                }
                if (state is AuthLoading) {
                  return const LoadingIndicator();
                }
                if (state is AuthAuthenticatedDermatologist) {
                  return const DermHomePage();
                }
                return const HomePage();
              },
            ),
          )
      ),
    );
  }
}