import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:khungulanga_app/repositories/notifications_repository.dart';
import 'package:khungulanga_app/repositories/slot_repository.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  initializeNotificationChannel();

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

void initializeNotificationChannel() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Handle foreground notifications
  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
  );

}

Future<void> initCamera() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  camera = firstCamera;
}

class App extends StatelessWidget {
  final UserRepository userRepository;
  late NotificationRepository notificationRepository;

  App({Key? key, required this.userRepository}) : super(key: key) {
    // Initialize Firebase
    initializeFirebase();
  }

  void initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    notificationRepository = NotificationRepository();

    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

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
void onNotificationResponse(NotificationResponse details) {
  log(details.payload ?? "New notification");
}
