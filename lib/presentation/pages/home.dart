import 'package:bsam_admin/app/game/detail/hook.dart';
import 'package:bsam_admin/app/jwt/jwt.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:bsam_admin/infrastructure/repository/token.dart';
import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/presentation/widgets/button.dart';
import 'package:bsam_admin/presentation/widgets/icon.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:bsam_admin/provider.dart';
import 'package:bsam_admin/router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

const maxMarkNo = 3;
const defaultWantMarkCounts = 3;

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

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
      appBar: HomeAppBar(
        associationName: Jwt.fromToken(tokenNotifier.state).associationName,
        onPressedLogout: () => logoutDialogBuilder(context, ref),
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Heading(
                raceDetail.value?.name ?? '読み込み中...',
                textAlign: TextAlign.center
              ),
            ),
            MarkingStartButtonArea(
              onPressed: (int markNo) {
                context.push('$markPagePathBase$markNo');
              }
            ),
            ManagingStartButton(
              onPressed: () {
                context.push(managePagePath);
              }
            ),
          ]
        )
      )
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String associationName;
  final void Function() onPressedLogout;

  const HomeAppBar({
    required this.associationName,
    required this.onPressedLogout,
    required this.preferredSize,
    super.key
  });

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      leading: const Padding(
        padding: EdgeInsets.only(left: 20),
        child: AppIcon(size: 32),
      ),
      title: Container(
        width: double.infinity,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999)
        ),
        alignment: Alignment.center,
        child: Text(
          associationName,
          style: const TextStyle(
            color: primaryColor,
            fontSize: bodyTextSize,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const LogoutIcon(
              size: 32,
              color: tertiaryColor
            ),
            onPressed: onPressedLogout
          )
        ),
      ]
    );
  }
}

// TODO: B-SAM っぽいデザインに変更する
Future<void> logoutDialogBuilder(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('本当にログアウトしますか？'),
        content: const Text('再度ログインするには、協会IDとパスワードの入力が必要です。'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('いいえ'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('はい'),
            onPressed: () async {
              await deleteToken(ref);
              if (context.mounted) {
                context.go(loginPagePath);
              }
            },
          ),
        ],
      );
    },
  );
}

class MarkingStartButtonArea extends StatelessWidget {
  final void Function(int) onPressed;

  const MarkingStartButtonArea({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 10,
        left: 30,
        right: 30,
      ),
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 1; i <= maxMarkNo; i++)
            MarkingStartButton(
              markNo: i,
              onPressed: onPressed,
            ),
        ]
      ),
    );
  }
}

class MarkingStartButton extends StatelessWidget {
  final int markNo;
  final void Function(int) onPressed;

  const MarkingStartButton({
    required this.markNo,
    required this.onPressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final markName = markLabels[defaultWantMarkCounts]![markNo - 1].name;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: SecondaryButton(
        label: '$markNameマークとして登録',
        onPressed: () => onPressed(markNo),
      ),
    );
  }
}

class ManagingStartButton extends StatelessWidget {
  final void Function() onPressed;

  const ManagingStartButton({
    required this.onPressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 50,
        left: 30,
        right: 30,
      ),
      child: PrimaryButton(
        label: 'レースを管理する',
        onPressed: onPressed
      )
    );
  }
}
