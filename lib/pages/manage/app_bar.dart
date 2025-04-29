import 'package:flutter/material.dart';

class ManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ManageAppBar({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context)
      )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
