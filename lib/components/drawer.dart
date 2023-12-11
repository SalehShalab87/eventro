import 'package:eventro/components/list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final Function()? onProfileTap;
  final Function()? onSignOutTap;
  final Function()? onFavoriteTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOutTap,
    required this.onFavoriteTap,
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
              DrawerHeader(
                child: Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_user?.photoURL ?? ''),
                    radius: 40,
                  ),
                ),
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: MyListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: widget.onSignOutTap,
            ),
          ),
        ],
      ),
    );
  }
}
