import 'package:bsam_admin/presentation/pages/check_permission.dart';
import 'package:go_router/go_router.dart';
import 'package:bsam_admin/presentation/pages/auth.dart';
import 'package:bsam_admin/presentation/pages/home.dart';
import 'package:bsam_admin/presentation/pages/login.dart';
import 'package:bsam_admin/presentation/pages/race.dart';

const checkPermissionPagePath = '/check_permission';
const authPagePath = '/auth';
const loginPagePath = '/login';
const homePagePath = '/';
const racePagePathBase = '/race/';

final GoRouter router = GoRouter(
  initialLocation: authPagePath,
  routes: [
    GoRoute(
      path: authPagePath,
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: checkPermissionPagePath,
      builder: (context, state) => const CheckPermissionPage(),
    ),
    GoRoute(
      path: loginPagePath,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: homePagePath,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '$racePagePathBase:athleteId',
      builder: (context, state) => RacePage(
        athleteId: state.pathParameters['athleteId']!,
      ),
    ),
  ],
);
