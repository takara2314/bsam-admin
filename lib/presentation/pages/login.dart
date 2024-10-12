import 'dart:async';
import 'dart:io';
import 'package:bsam_admin/app/auth/auth.dart';
import 'package:bsam_admin/app/inapp_notification/inapp_notification.dart';
import 'package:bsam_admin/infrastructure/repository/token.dart';
import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/presentation/widgets/button.dart';
import 'package:bsam_admin/presentation/widgets/icon.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:bsam_admin/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends HookConsumerWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _associationIdFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    void submitForm() {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      submitting.value = true;

      showNotificationNormal(
        context,
        'ログインしています...\n20秒ほどかかることがあります...',
        durationSec: 20
      );

      verifyPassword(
        _associationIdFieldController.text,
        _passwordFieldController.text
      )
        .then((res) {
          // ログイン成功したら、トークンを保存してホームページに推移する
          if (context.mounted) {
            hideNotification(context);
            saveToken(ref, res.token);
            context.go(homePagePath);
          }
        })
        .catchError((error) {
          // サーバーに接続できない or タイムアウトなら、サーバーエラーと表示
          if (error is SocketException || error is TimeoutException) {
            if (context.mounted) {
              showNotificationWarning(
                context,
                'サーバーエラーが発生しました'
              );
            }

          // タイムアウト以外のエラーは認証失敗とみなす
          } else if (context.mounted) {
            showNotificationError(
              context,
              'IDまたはパスワードが間違っています'
            );
          }
          submitting.value = false;
        });
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Introduction(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 450,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      '協会ID',
                      enabled: !submitting.value,
                      controller: _associationIdFieldController,
                    ),
                    InputField(
                      'パスワード',
                      obscured: true,
                      enabled: !submitting.value,
                      controller: _passwordFieldController,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: PrimaryButton(
                        label: 'ログイン',
                        onPressed: submitting.value ? null : submitForm,
                      )
                    )
                  ]
                )
              )
            )
          ),
        ],
      )
    );
  }
}

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 100, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: const AppIcon(
              size: 100
            )
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(
                  'セーリングを',
                  fontSize: 28,
                  color: primaryColor
                ),
                Heading(
                  'すべての人に。',
                  fontSize: 28,
                  color: primaryColor
                ),
                Heading(
                  '私がマークまで安全に',
                  fontSize: 28
                ),
                Heading(
                  'ナビゲーションします。',
                  fontSize: 28
                )
              ]
            )
          ),
        ]
      )
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final bool obscured;
  final bool enabled;
  final TextEditingController controller;

  const InputField(
    this.label,
    {
      this.obscured = false,
      required this.enabled,
      required this.controller,
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NormalText(label)
          ),
          TextFormField(
            controller: controller,
            enabled: enabled,
            obscureText: obscured,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none
              ),
              filled: true,
              fillColor: backgroundColor,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$labelを入力してください';
              }
              return null;
            },
          )
        ]
      )
    );
  }
}
