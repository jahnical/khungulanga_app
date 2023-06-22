import 'package:khungulanga_app/widgets/appointment/appointments_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/blocs/auth_bloc/auth_bloc.dart';
import 'package:khungulanga_app/blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:khungulanga_app/widgets/appointment/appointments_page.dart';
import 'package:khungulanga_app/widgets/profile/derm_profile.dart';

import '../../repositories/user_repository.dart';
import '../notification/notifications_page.dart';
import '../results/results_page.dart';
import '../slots/derm_slots.dart';

class DermHomePage extends StatefulWidget {
  const DermHomePage({Key? key}) : super(key: key);

  @override
  _DermHomePageState createState() => _DermHomePageState();
}

class _DermHomePageState extends State<DermHomePage> {
  final List<String> _titles = ['Results', 'Appointments', 'Slots'];

  final List<Widget> _pages = [
    ResultsPage(),
    AppointmentList(completed: false),
    DermatologistSlotsPage(),
  ];

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
        });
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
              child: Text('Khungulanga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          ListTile(
            title: Text('Profile'),
            leading: Icon(Icons.person),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DermatologistProfilePage(dermatologist: RepositoryProvider.of<UserRepository>(context).dermatologist!),
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
                        Text(
                            'Khungulanga is a mobile application that uses machine learning for early skin diagnosis and connects users with dermatologists for expert advice.'),
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

  final events = [
    NavigateToResults(),
    NavigateToAppointments(),
    NavigateToSlots(),
  ];
  _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(),
      onTap: (int index) {
        context.read<HomeNavigationBloc>().add(events[index]);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Results',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_view_week),
          label: 'Slots',
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    return context.read<HomeNavigationBloc>().state is HomeNavigationAppointments ? 1 :
      context.read<HomeNavigationBloc>().state is HomeNavigationSlots ? 2 : 0;
  }
}