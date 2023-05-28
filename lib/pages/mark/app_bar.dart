import 'package:flutter/material.dart';

import 'package:bsam_admin/pages/mark/pop_dialog.dart';

class MarkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MarkAppBar({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => isPopDialog(context)
      )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
