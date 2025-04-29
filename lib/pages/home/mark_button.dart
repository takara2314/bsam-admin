import 'package:flutter/material.dart';

import 'package:bsam_admin/models/user.dart';
import 'package:bsam_admin/pages/mark/page.dart';

class MarkButton extends StatelessWidget {
  const MarkButton({
    super.key,
    required this.assocId,
    required this.mark
  });

  final String? assocId;
  final User mark;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        '${mark.displayName}をおく'
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Mark(
              assocId: assocId!,
              userId: mark.id!,
              markNo: mark.markNo!
            )
          )
        );
      }
    );
  }
}
