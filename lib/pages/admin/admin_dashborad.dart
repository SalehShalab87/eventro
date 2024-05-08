// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/show_error_message.dart';
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
              onPressed: () => signAdminOut(context),
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

  Future<void> signAdminOut(BuildContext context) async {
    try {
      // Show the sign-out confirmation dialog
      bool shouldSignOut = await showSignOutConfirmationDialog(context);

      // Check if the user confirmed the sign-out
      if (shouldSignOut) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    } catch (e) {
      String errorMessage = "Failed to sign out admin.";
      showErrorMessage(context, errorMessage);
    }
  }

  Future<bool> showSignOutConfirmationDialog(BuildContext context) async {
    // Return a Future<bool> to indicate whether the user confirmed the sign-out
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Sign Out Confirmation'),
            content: const Text('Are you sure you want to sign out?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext)
                      .pop(true); // Close the dialog and return false
                },
                child: _buildSignOutButton('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext)
                      .pop(false); // Close the dialog and return true
                },
                child: _buildSignOutButton('NO'),
              ),
            ],
          ),
        ) ??
        false; // Provide a default value if the user dismisses the dialog
  }

  Widget _buildSignOutButton(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(
        color: Color(0xffEC6408),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.black)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
        ],
      ),
    );
  }
}
