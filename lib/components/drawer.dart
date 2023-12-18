import 'package:eventro/components/list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final Function()? onProfileTap;
  final Function()? onSignOutTap;
  final Function()? onFavoriteTap;
  final Function()? onEventsTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOutTap,
    required this.onFavoriteTap,
    required this.onEventsTap,
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xffEC6408),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const DrawerHeader(
                child: Center(
                    child: Icon(
                  Icons.person_outline,
                  size: 120,
                )),
              ),
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: widget.onProfileTap,
              ),
              MyListTile(
                icon: Icons.favorite,
                text: 'F A V O R I T E',
                onTap: widget.onFavoriteTap,
              ),
              MyListTile(
                icon: Icons.event,
                text: 'E V E N T S',
                onTap: widget.onEventsTap,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: MyListTile(
              icon: Icons.logout_outlined,
              text: 'L O G O U T',
              onTap: widget.onSignOutTap,
            ),
          ),
        ],
      ),
    );
  }
}
