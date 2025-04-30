import 'package:flutter/material.dart';

import 'package:bsam_admin/pages/manage/page.dart';

class ManageButton extends StatelessWidget {
  const ManageButton({
    super.key,
    required this.assocId
  });

  final String? assocId;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // Get screen width

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox( // Wrap ElevatedButton with SizedBox
        width: width * 0.9, // Set width to 90% of screen width
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.grey[300], // Keep original background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20) // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 20) // Vertical padding
          ),
          child: const Text(
            'レースを管理する',
            style: TextStyle( // Apply text style (keep original color)
              // color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20
            )
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Manage(assocId: assocId!),
              )
            );
          }
        ),
      ),
    );
  }
}
