import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/auth_bloc/auth_bloc.dart';
import 'package:khungulanga_app/blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/appointment/appointment_chats.dart';
import 'package:khungulanga_app/widgets/appointment/appointments_page.dart';
import 'package:khungulanga_app/widgets/dermatologists/dermatologists_list.dart';
import 'package:khungulanga_app/widgets/diseases/diseases_page.dart';
import 'package:khungulanga_app/widgets/history/history_page.dart';
import 'package:khungulanga_app/widgets/notification/notifications_page.dart';
import '../profile/patient_profile.dart';
import '../scan/scan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _titles = ['History', 'Scan', 'Dermatologists'];

  final List<Widget> _pages = [const HistoryPage(), ScanPage(), DermatologistList(userLocation: [0.0, 0.0],),];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeNavigationBloc, HomeNavigationState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[_getCurrentIndex()]),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ));
                  },
                ),
              ],
            ),
            drawer: _buildDrawer(),
            body: _pages[_getCurrentIndex()],
            bottomNavigationBar: _buildBottomNavigation(),
          );
        }
    );
  }

  _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Text(
                  'KhunguLanga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )
              ),
            ),
          ),
          ListTile(
            title: Text('Profile'),
            leading: Icon(Icons.person),
            onTap: () {
              // Navigate to the profile screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PatientProfilePage(patient: RepositoryProvider.of<UserRepository>(context).patient!),
              ));
            },
          ),
          ExpansionTile(
            title: Text('Appointments'),
            leading: Icon(Icons.calendar_today),
            children: [
              ListTile(
                title: Text('Scheduled Appointments'),
                leading: Icon(Icons.schedule),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AppointmentsPage(completed: false),
                  ));
                },
              ),
              ListTile(
                title: Text('Completed Appointments'),
                leading: Icon(Icons.check_circle),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AppointmentsPage(completed: true),
                  ));
                },
              ),
              ListTile(
                title: Text('Cancelled Appointments'),
                leading: Icon(Icons.cancel),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AppointmentsPage(completed: false, cancelled: true),
                  ));
                },
              ),
            ],
          ),
          ListTile(
            title: Text('Diseases'),
            leading: Icon(Icons.local_hospital),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DiseasesPage(),
              ));
            },
          ),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Khungulanga'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Version: 1.0.0'),
                        SizedBox(height: 16),
                        Text('Khungulanga is a mobile application that uses machine learning for early skin diagnosis and connects users with dermatologists for expert advice.'),
                        SizedBox(height: 16),
                        Text('Developed by: ICT Group 7'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.logout),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(LoggedOut());
                        Navigator.of(context).pop();
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  final events = [NavigateToHistory(), NavigateToScan(), NavigateToDermatologists()];
  _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(),
      onTap: (int index) {
        if (index == 1 && _getCurrentIndex() == 1) {
          (_pages[1] as ScanPage).captureCall();
        } else {
          context.read<HomeNavigationBloc>().add(events[index]);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera, size: 42, color: Colors.purpleAccent,),
          label: 'Scan',
          activeIcon: Icon(Icons.camera, size: 42),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Dermatologists',
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    return context.read<HomeNavigationBloc>().state is HomeNavigationHistory? 0
        : context.read<HomeNavigationBloc>().state is HomeNavigationScan? 1 : 2;
  }
}