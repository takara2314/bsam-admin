import 'package:flutter/material.dart';

class PopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PopAppBar({
    Key? key,
    required this.pageName
  }) : super(key: key);

  final String pageName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context)
      ),
      title: Text(
        pageName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16
        )
      )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
