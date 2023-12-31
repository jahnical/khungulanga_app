import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:khungulanga_app/repositories/clinic_repository.dart';
import 'package:khungulanga_app/repositories/dermatologist_repository.dart';
import 'package:khungulanga_app/repositories/notifications_repository.dart';
import 'package:khungulanga_app/repositories/patient_repository.dart';
import 'package:khungulanga_app/repositories/slot_repository.dart';
import 'firebase_options.dart';
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

/// A custom [BlocObserver] that logs bloc events, transitions, and errors.
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initCamera();
  APIClient.setupCacheInterceptor();
  Bloc.observer = SimpleBlocObserver();
  final userRepository = UserRepository();

  runApp(
    BlocProvider<AuthBloc>(
      create: (context) {
        return AuthBloc(userRepository: userRepository)
          ..add(AppStarted(context));
      },
      child: App(userRepository: userRepository),
    ),
  );
}

/// Initializes the camera for scanning.
Future<void> initCamera() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  camera = firstCamera;
}

/// The root widget of the application.
class App extends StatelessWidget {
  final UserRepository userRepository;
  late NotificationRepository notificationRepository;

  App({Key? key, required this.userRepository}) : super(key: key) {
    // Initialize Firebase
    initialize();
  }

  /// Initializes Firebase and sets up the notification repository.
  void initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    notificationRepository = NotificationRepository();

    setupInteractedMessage();
  }

  /// Sets up the handling of interactive notification messages.
  Future<void> setupInteractedMessage()async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// Handles the received message.
  void _handleMessage(RemoteMessage message) {
    log('Handling a background message ${message.messageId}');
    log(message.data.toString());
    log(message.notification.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DiagnosisRepository()),
        RepositoryProvider(create: (context) => userRepository),
        RepositoryProvider(create: (context) => DiseaseRepository()),
        RepositoryProvider(create: (context) => AppointmentRepository()),
        RepositoryProvider(create: (context) => notificationRepository),
        RepositoryProvider(create: (context) => SlotRepository()),
        RepositoryProvider(create: (context) => DermatologistRepository()),
        RepositoryProvider(create: (context) => ClinicRepository()),
        RepositoryProvider(create: (context) => PatientRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => DermatologistsBloc(userLocation: [0.0, 0.0])
              ..add(LoadDermatologistsEvent()),
          ),
          BlocProvider(create: (context) => HomeNavigationBloc()),
          BlocProvider(
            create: (context) => DiagnosisBloc(repository: context.read<DiagnosisRepository>())
              ..add(FetchDiagnoses()),
          ),
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
        ),
      ),
    );
  }
}
