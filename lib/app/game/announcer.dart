import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/voice/voice.dart';
import 'package:bsam_admin/domain/direction.dart';
import 'package:bsam_admin/domain/distance.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:bsam_admin/app/game/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const periodicAnnounceInterval = Duration(seconds: 3);
const passedAnnounceTimes = 3;
const passedAnnounceInterval = Duration(seconds: 1);
const shortPauseInterval = Duration(milliseconds: 10);

// マークの方向と距離をアナウンスするフック
Future<void> Function(int) useAnnouncer(
  BuildContext context,
  WidgetRef ref,
  UseVoice voice,
  GameClientState gameState,
) {
  bool startedPeriodicAnnounce = false;
  final enabledPeriodicAnnounce = useState(false);

  final compassDegree = useState<double?>(null);
  final distanceToNextMarkMeter = useState<double?>(null);
  final nextMarkNo = useState<int?>(null);

  final invalidMarkAnnounceCount = useState(0);

  // マークの方向と距離をアナウンスする
  Future<void> announceMarkDirectionDistance() async {
    // コンパスの角度と次のマークまでの距離が不明の場合
    if (compassDegree.value == null || distanceToNextMarkMeter.value == null) {
      // 3回チェックしても不明なら「次のマークがどこにあるかわかりません」とアナウンスする
      invalidMarkAnnounceCount.value++;
      if (invalidMarkAnnounceCount.value > 3) {
        await voice.speak('次のマークがどこにあるかわかりません');
      }
      return;
    }
    invalidMarkAnnounceCount.value = 0;

    if (!context.mounted) {
      return;
    }
    final wantMarkCounts = ref.watch(wantMarkCountsProvider);

    final markNameKatakana = getMarkLabel(wantMarkCounts, nextMarkNo.value!).nameKatakana;
    final directionName = getDirectionName(compassDegree.value!);
    final distance = getAnnounceDistanceMeter(distanceToNextMarkMeter.value!);

    await voice.speak('$markNameKatakana、$directionName、$distance');
  }

  // マーク通過を1回アナウンスする
  Future<void> announcePassedOnce(int passedMarkNo) async {
    if (!context.mounted) {
      return;
    }
    final wantMarkCounts = ref.watch(wantMarkCountsProvider);

    final markNameKatakana = getMarkLabel(wantMarkCounts, passedMarkNo).nameKatakana;
    await voice.speak('$markNameKatakanaに到達');
  }

  // マーク通過を複数回アナウンスする
  Future<void> announceMarkPassedRepeatedly(int passedMarkNo) async {
    for (int i = 0; i < passedAnnounceTimes; i++) {
      await announcePassedOnce(passedMarkNo);

      if (context.mounted) {
        await Future.delayed(passedAnnounceInterval);
      } else {
        return;
      }
    }
  }

  // 定期的なアナウンスを開始する
  Future<void> startPeriodicAnnounce(Duration interval) async {
    if (startedPeriodicAnnounce) {
      return;
    }
    startedPeriodicAnnounce = true;

    while (true) {
      // 定期的なアナウンスが無効ならスルー
      if (!enabledPeriodicAnnounce.value) {
        await Future.delayed(shortPauseInterval);
        continue;
      }

      if (!context.mounted) {
        return;
      }
      await announceMarkDirectionDistance();

      if (context.mounted) {
        await Future.delayed(interval);
      } else {
        return;
      }
    }
  }

  void stopVoice() {
    voice.stop();
  }

  // マーク通過時に呼び出されるコールバック関数
  // マーク通過アナウンス時は定期アナウンスを無効にする
  Future<void> callbackOnPassedMark(int passedMarkNo) async {
    if (!context.mounted) {
      return;
    }
    enabledPeriodicAnnounce.value = false;

    await announceMarkPassedRepeatedly(passedMarkNo);

    if (!context.mounted || !gameState.started) {
      return;
    }
    enabledPeriodicAnnounce.value = true;
  }

  // 定期的なアナウンスを開始する
  useEffect(() {
    startPeriodicAnnounce(periodicAnnounceInterval);
    return stopVoice;
  }, []);

  // レース開始時 -> 定期的なアナウンスを有効にする
  // レース終了時 -> 定期的なアナウンスを無効にする
  useEffect(() {
    enabledPeriodicAnnounce.value = gameState.started;
    return stopVoice;
  }, [gameState.started]);

  // 定期的なアナウンスが無効になればアナウンスを強制停止する
  useEffect(() {
    if (!enabledPeriodicAnnounce.value) {
      stopVoice();
    }
    return stopVoice;
  }, [enabledPeriodicAnnounce.value]);

  // クライアントの状態をローカルステートに同期
  useEffect(() {
    compassDegree.value = gameState.compassDegree;
    return null;
  }, [gameState.compassDegree]);

  useEffect(() {
    distanceToNextMarkMeter.value = gameState.distanceToNextMarkMeter;
    return null;
  }, [gameState.distanceToNextMarkMeter]);

  useEffect(() {
    nextMarkNo.value = gameState.nextMarkNo;
    return null;
  }, [gameState.nextMarkNo]);

  return callbackOnPassedMark;
}
