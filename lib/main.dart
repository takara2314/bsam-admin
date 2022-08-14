import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsam_admin/pages/home.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-SAM',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.cyan,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary
          ),
          headline2: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          headline3: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          headline4: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
          headline5: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
          headline6: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold
          ),
          bodyText1: const TextStyle(
            fontSize: 18
          ),
          bodyText2: const TextStyle(
            fontSize: 16
          ),
          button: const TextStyle(
            fontSize: 14
          ),
          caption: const TextStyle(
            fontSize: 12
          ),
          overline: const TextStyle(
            fontSize: 10
          )
        )
      ),
      home: const Home(),
    );
  }
}
