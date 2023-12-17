import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  final String tilte;
  final IconData iconData;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textcolor;

  const ProfileMenuWidget({
    super.key,
    required this.tilte,
    required this.iconData,
    required this.onPress,
    this.endIcon = true,
    this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color.fromRGBO(158, 158, 158, 1).withOpacity(0.1)),
        child: Icon(
          iconData,
          color: const Color(0xffEC6408),
        ),
      ),
      title: Text(
        tilte,
        style: TextStyle(color: textcolor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(0.1)),
              child: const Icon(
                LineAwesomeIcons.angle_right,
                color: Color(0xffEC6408),
                size: 18.0,
              ),
            )
          : null,
    );
  }
}
