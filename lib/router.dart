import 'package:bsam_admin/presentation/pages/check_permission.dart';
import 'package:bsam_admin/presentation/pages/manage.dart';
import 'package:bsam_admin/presentation/pages/mark.dart';
import 'package:go_router/go_router.dart';
import 'package:bsam_admin/presentation/pages/auth.dart';
import 'package:bsam_admin/presentation/pages/home.dart';
import 'package:bsam_admin/presentation/pages/login.dart';

const checkPermissionPagePath = '/check_permission';
const authPagePath = '/auth';
const loginPagePath = '/login';
const homePagePath = '/';
const markPagePathBase = '/marking/';
const managePagePath = '/manage';

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
      path: '$markPagePathBase:markNo',
      builder: (context, state) => MarkPage(
        markNo: int.parse(state.pathParameters['markNo']!),
      ),
    ),
    GoRoute(
      path: managePagePath,
      builder: (context, state) => const ManagePage(),
    ),
  ],
);
