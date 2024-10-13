import 'package:bsam_admin/app/game/engine.dart';
import 'package:bsam_admin/app/game/state.dart';
import 'package:bsam_admin/domain/athlete.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// グローバルな状態管理のためのProviders
final associationIdProvider = StateProvider<String>((ref) => '');
final deviceIdProvider = StateProvider<String>((ref) => '');
final wantMarkCountsProvider = StateProvider<int>((ref) => 0);

// ゲームクライアントの状態を管理するProvider
final gameClientProvider = StateNotifierProvider.autoDispose<GameClientNotifier, GameClientState>((ref) {
  return GameClientNotifier(ref);
});

// ゲームクライアントの状態を管理するNotifier
class GameClientNotifier extends StateNotifier<GameClientState> {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;

  late final GameEngine engine;

  GameClientNotifier(this._ref) : super(
    const GameClientState(
      connected: false,
      authed: false,
      started: false,
      marks: null,
      athletes: null,
    )
  ) {
    engine = GameEngine(_ref, this);
  }

  // 公開メソッド
  void connect() => engine.ws.connect();
  void disconnect() => engine.ws.disconnect();
  void manageNextMark(String targetDeviceId, int nextMarkNo) => engine.manageNextMark(targetDeviceId, nextMarkNo);

  // ステートのgetterとsetter
  bool get connected => state.connected;
  set connected(bool value) {
    state = state.copyWith(connected: value);
  }

  bool get authed => state.authed;
  set authed(bool value) {
    state = state.copyWith(authed: value);
  }

  bool get started => state.started;
  set started(bool value) {
    state = state.copyWith(started: value);
  }

  List<MarkGeolocation>? get marks => state.marks;
  set marks(List<MarkGeolocation>? value) {
    state = state.copyWith(marks: value);
  }

  List<AthleteInfo>? get athletes => state.athletes;
  set athletes(List<AthleteInfo>? value) {
    state = state.copyWith(athletes: value);
  }
}
