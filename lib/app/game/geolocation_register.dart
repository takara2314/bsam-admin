import 'package:bsam_admin/app/game/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';

// 位置情報の登録を行うフック
void useGeolocationRegister(
  BuildContext context,
  GameClientNotifier client,
  GeolocationState geolocation,
) {
  useEffect(() {
    Future.microtask(() {
      if (!client.connected || !geolocation.fetched || !context.mounted) {
        return;
      }
      client.registerGeolocation(geolocation);
    });

    return null;
  }, [geolocation]);
}
