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
    final width = MediaQuery.of(context).size.width; // Get screen width

    return SizedBox(
      width: width * 0.9, // Set width to 90% of screen width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Use project's red color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20) // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 20) // Vertical padding
        ),
        child: Text(
          '${mark.displayName}をおく',
          style: const TextStyle( // Apply text style
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20
          )
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
      ),
    );
  }
}
