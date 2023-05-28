import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    Key? key,
    required this.assocName
  }) : super(key: key);

  final String assocName;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'images/logo.svg',
            semanticsLabel: 'logo',
            width: 42,
            height: 42
          ),
          Container(
            width: width * 0.6,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999)
            ),
            child: Text(
              assocName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16
              )
            )
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 32,
            onPressed: () {}
          )
        ]
      )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
