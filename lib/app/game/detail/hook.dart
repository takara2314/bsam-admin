import 'package:bsam_admin/app/game/detail/fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_use/flutter_use.dart';

const pollingInterval = Duration(seconds: 3);

ValueNotifier<RaceDetailResponse?> useRaceDetail(
  BuildContext context,
  String associationId,
  String token,
) {
  final raceDetail = useState<RaceDetailResponse?>(null);

  void fetchAndUpdate() {
    fetchRaceDetail(associationId, token)
      .then((response) {
        raceDetail.value = response;
      });
  }

  useEffect(() {
    fetchAndUpdate();
    return null;
  }, []);

  return raceDetail;
}


ValueNotifier<RaceDetailResponse?> useRaceDetailAlwaysFetch(
  BuildContext context,
  String associationId,
  String token,
  ValueNotifier<bool> isActive,
) {
  final raceDetail = useState<RaceDetailResponse?>(null);

  void fetchAndUpdate() {
    if (!isActive.value) {
      return;
    }
    fetchRaceDetail(associationId, token)
      .then((response) {
        raceDetail.value = response;
      });
  }

  useInterval(fetchAndUpdate, pollingInterval);

  useEffect(() {
    if (isActive.value) {
      fetchAndUpdate();
    }
    return null;
  }, [isActive.value]);

  return raceDetail;
}
