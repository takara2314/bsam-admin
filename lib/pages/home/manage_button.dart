import 'package:flutter/material.dart';

import 'package:bsam_admin/pages/manage/page.dart';

class ManageButton extends StatelessWidget {
  const ManageButton({
    Key? key,
    required this.assocId
  }) : super(key: key);

  final String? assocId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: ElevatedButton(
        child: const Text(
          'レースを管理する'
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Manage(assocId: assocId!),
            )
          );
        }
      ),
    );
  }
}
