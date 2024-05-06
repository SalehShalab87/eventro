import 'package:eventro/pages/admin/admin_events.dart';
import 'package:eventro/pages/admin/admin_home.dart';
import 'package:eventro/pages/admin/admin_notifcation.dart';
import 'package:eventro/pages/admin/admin_profile.dart';
import 'package:eventro/pages/admin/users_page.dart';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

// page index
int _currnetindex = 0;

//list for the nav bar
List<Widget> _pages = <Widget>[
  //home Page
  const AdminHomePage(),
  //users Page
  const UsersPage(),
  //events Page
  const AdminEventsPage(),
  //profile Page
  const AdminProfilePage(),
];

class _AdminPageState extends State<AdminPage> {
  // page index
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false),
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 5, left: 12),
                child: Icon(
                  Icons.logout,
                  size: 30,
                  color: Colors.black,
                ),
              )),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminNotifcation(),
                    )),
                icon: const Icon(
                  Icons.notifications_active_outlined,
                  size: 30,
                  color: Colors.black,
                ))
          ],
        ),
        body: SafeArea(child: _pages.elementAt(_currnetindex)),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: GNav(
            tabBackgroundColor: const Color(0xffEC6408),
            padding: const EdgeInsets.all(16),
            gap: 8,
            selectedIndex: _currnetindex,
            onTabChange: (index) {
              setState(() {
                _currnetindex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'H O M E',
              ),
              GButton(
                icon: Icons.man,
                text: 'U S E R S',
              ),
              GButton(
                icon: Icons.event,
                text: 'E V E N T S',
              ),
              GButton(
                icon: Icons.person,
                text: 'P R O F I L E',
              )
            ],
          ),
        ));
  }
}
