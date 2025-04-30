import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:bsam_admin/pages/home/page.dart';

Future<void> main() async {
  // クラッシュハンドラ
  runZonedGuarded<Future<void>>(() async {
    // 環境変数ファイルの読み込み
    await dotenv.load(fileName: '.env');

    // Firebaseの初期化
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // クラッシュハンドラ (Flutterフレームワーク内でスローされたすべてのエラー)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 画面の向きを縦に固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(const ProviderScope(child: App()));
  },
    // クラッシュハンドラ (Flutterフレームワーク内でキャッチされないエラー)
    (error, stack) =>
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-SAM 本部用',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          backgroundColor: Colors.transparent,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          headlineMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
          headlineSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
          titleLarge: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold
          ),
          bodyLarge: const TextStyle(
            fontSize: 18
          ),
          bodyMedium: const TextStyle(
            fontSize: 16
          ),
          labelLarge: const TextStyle(
            fontSize: 14
          ),
          bodySmall: const TextStyle(
            fontSize: 12
          ),
          labelSmall: const TextStyle(
            fontSize: 10
          )
        )
      ),
      home: const Home()
    );
  }
}
