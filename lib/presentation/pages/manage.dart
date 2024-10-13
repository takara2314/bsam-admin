import 'package:bsam_admin/app/game/detail/hook.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bsam_admin/app/jwt/jwt.dart';
import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/provider.dart';

class ManagePage extends HookConsumerWidget {
  const ManagePage({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenNotifier = ref.watch(tokenProvider.notifier);
    final jwt = Jwt.fromToken(tokenNotifier.state);

    final raceDetail = useRaceDetail(
      context,
      jwt.associationId,
      tokenNotifier.state,
    );

    return Scaffold(
      appBar: ManageAppBar(
        raceName: raceDetail.value?.name ?? '',
        preferredSize: const Size.fromHeight(72),
      ),
      body: const Center(
        child: Text('管理画面')
      )
    );
  }
}

class ManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String raceName;

  const ManageAppBar({
    required this.raceName,
    required this.preferredSize,
    super.key
  });

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: false,
      title: Text(
        raceName,
        style: const TextStyle(
          color: bodyTextColor,
          fontSize: bodyTextSize,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
