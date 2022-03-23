import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailing_assist_mie_admin/pages/home.dart';
import 'package:sailing_assist_mie_admin/pages/place/races.dart';
import 'package:sailing_assist_mie_admin/pages/place/course.dart';
import 'package:sailing_assist_mie_admin/pages/manage/races.dart';
import 'package:sailing_assist_mie_admin/pages/manage/course.dart';
import 'package:sailing_assist_mie_admin/pages/settings.dart';

final routerProvider = Provider((ref) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(
        child: Home()
      )
    ),
    GoRoute(
      path: '/place/races',
      pageBuilder: (context, state) => const MaterialPage(
        child: PlaceRaces()
      )
    ),
    GoRoute(
      path: '/place/course/:raceId',
      pageBuilder: (context, state) => MaterialPage(
        child: PlaceCourse(raceId: state.params['raceId'] ?? '')
      )
    ),
    GoRoute(
      path: '/manage/races',
      pageBuilder: (context, state) => const MaterialPage(
        child: ManageRaces()
      )
    ),
    GoRoute(
      path: '/manage/course/:raceId',
      pageBuilder: (context, state) => MaterialPage(
        child: ManageCourse(raceId: state.params['raceId'] ?? '')
      )
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const MaterialPage(
        child: Settings()
      )
    )
  ]
));
