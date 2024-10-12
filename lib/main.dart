import 'package:bsam_admin/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 本番環境
// const apiServerBaseUrl = 'https://stg.api.bsam.app';
// const authServerBaseUrl = 'https://stg.auth.bsam.app';
// const gameServerBaseUrlWs = 'wss://stg.game.bsam.app';

// 開発環境 (Android)
const apiServerBaseUrl = 'http://10.0.2.2:8080';
const authServerBaseUrl = 'http://10.0.2.2:8082';
const gameServerBaseUrlWs = 'ws://10.0.2.2:8081';

// 開発環境 (iOS)
// const apiServerBaseUrl = 'http://localhost:8080';
// const authServerBaseUrl = 'http://localhost:8082';
// const gameServerBaseUrlWs = 'ws://localhost:8081';

const bodyTextSize = 16.0;
const bodyHeadingSize = 20.0;

const bodyTextColor = Color.fromARGB(255, 62, 62, 62);
const primaryColor = Color.fromARGB(255, 149, 22, 0);
const secondaryColor = Color.fromARGB(255, 255, 84, 79);
const tertiaryColor = Color.fromARGB(255, 124, 124, 124);

const backgroundColor = Color.fromARGB(255, 242, 242, 242);

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 画面の向きを縦に固定
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp.router(
      title: 'B-SAM 本部用',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
