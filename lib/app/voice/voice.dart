import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tts/flutter_tts.dart';
import "package:async_locks/async_locks.dart";

class UseVoice {
  final String language;
  final double speechRate;
  final double volume;
  final double pitch;
  final Function(String) speak;
  final Future<dynamic> Function() stop;

  UseVoice({
    required this.language,
    required this.speechRate,
    required this.volume,
    required this.pitch,
    required this.speak,
    required this.stop,
  });
}

UseVoice useVoice(String language, double speechRate, double volume, double pitch) {
  final tts = useMemoized(() => FlutterTts(), []);
  final lock = useMemoized(() => Lock(), []);

  bool forcedStop = false;

  initTts() async {
    await tts.setLanguage(language);
    await tts.setSpeechRate(speechRate);
    await tts.setVolume(volume);
    await tts.setPitch(pitch);
    await tts.awaitSpeakCompletion(true);
  }

  useEffect(() {
    initTts();
    return () {
      tts.stop();
    };
  }, []);

  String correctTextPreSpeak(String text) {
    // なぜかAndroidのみ 46 のみ英語の発音なので、ひらがな読みにする
    text = text.replaceAll('46', 'よんじゅうろく');
    return text;
  }

  speak(String text) async {
    forcedStop = false;
    await lock.run(() async {
      if (forcedStop) {
        return;
      }
      await tts.speak(correctTextPreSpeak(text));
    });
  }

  stop() async {
    forcedStop = true;
    tts.stop();
  }

  return UseVoice(
    language: language,
    speechRate: speechRate,
    volume: volume,
    pitch: pitch,
    speak: speak,
    stop: stop,
  );
}
