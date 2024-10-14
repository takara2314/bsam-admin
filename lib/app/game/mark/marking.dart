import 'package:bsam_admin/app/game/mark/post.dart';
import 'package:bsam_admin/utils/double.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';

const sendingIntervalMilliseconds = 3000;

class UseMarking {
  final ValueNotifier<bool> isLocationSent;
  final void Function(bool isSendingManualLocation, double lat, double lng) registerManualLocation;

  UseMarking({
    required this.isLocationSent,
    required this.registerManualLocation,
  });
}

UseMarking useMarking(String token, int markNo) {
  final isLocationSent = useState(false);

  void onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      isLocationSent.value = data["is_location_sent"];
    }
  }

  void initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_service',
        channelName: 'Location Service',
        channelDescription:
          'This notification appears when the location service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // イベントのアクション間隔を3秒(3000ミリ秒)に設定
        eventAction: ForegroundTaskEventAction.repeat(sendingIntervalMilliseconds),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    final sendingIntervalSecondForLabel = doubleToString(
      sendingIntervalMilliseconds / 1000,
    );

    await FlutterForegroundTask.startService(
      notificationTitle: 'マークの位置を送信中',
      notificationText: '$sendingIntervalSecondForLabel秒に1回、B-SAMのサーバーに位置情報を送信します',
      callback: startCallback,
    );

    // TODO: 500ミリ秒ほど待たないと正常にデータを送れない現象の原因調査をする
    await Future.delayed(const Duration(milliseconds: 500));

    FlutterForegroundTask.sendDataToTask({
      "type": "init",
      "token": token,
      "markNo": markNo,
    });
  }

  void registerManualLocation(
    bool isSendingManualLocation,
    double lat,
    double lng,
  ) {
    FlutterForegroundTask.sendDataToTask({
      "type": "manual_location",
      "is_sending_manual_location": isSendingManualLocation,
      "manual_latitude": lat,
      "manual_longitude": lng,
    });
  }

  useEffect(() {
    FlutterForegroundTask.addTaskDataCallback(onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initService();
    });

    return () {
      FlutterForegroundTask.removeTaskDataCallback(onReceiveTaskData);
      FlutterForegroundTask.stopService();
    };
  }, []);

  return UseMarking(
    isLocationSent: isLocationSent,
    registerManualLocation: registerManualLocation,
  );
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  String? token;
  int? markNo;

  bool isSendingManualLocation = false;
  double? manualLatitude;
  double? manualLongitude;

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final taskData = await FlutterForegroundTask.getData<Map<String, dynamic>>(
      key: 'taskData'
    );
    token = taskData?['token'] as String?;
    markNo = taskData?['markNo'] as int?;
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (token == null || markNo == null) {
      return;
    }

    final locationData = await getLocationData();
    postGeolocationData(locationData)
      .then((_) {
        FlutterForegroundTask.sendDataToMain({
          "is_location_sent": true,
        });
      });
  }

  Future<Map<String, double>> getLocationData() async {
    if (isSendingManualLocation) {
      return {
        'latitude': manualLatitude ?? 0.0,
        'longitude': manualLongitude ?? 0.0,
        'accuracyMeter': 0.0,
        'altitudeMeter': 0.0,
        'altitudeAccuracyMeter': 0.0,
        'heading': 0.0,
        'speedMeterPerSec': 0.0,
      };
    } else {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracyMeter': position.accuracy,
        'altitudeMeter': 0.0,
        'altitudeAccuracyMeter': 0.0,
        'heading': 0.0,
        'speedMeterPerSec': 0.0,
      };
    }
  }

  Future<void> postGeolocationData(Map<String, double> locationData) async {
    try {
      await postGeolocation(
        token: token!,
        deviceId: 'mark$markNo',
        latitude: locationData['latitude']!,
        longitude: locationData['longitude']!,
        altitudeMeter: locationData['altitudeMeter']!,
        accuracyMeter: locationData['accuracyMeter']!,
        altitudeAccuracyMeter: locationData['altitudeAccuracyMeter']!,
        heading: locationData['heading']!,
        speedMeterPerSec: locationData['speedMeterPerSec']!,
        recordedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Failed to send location information: $e');
      rethrow;
    }
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      switch (data["type"]) {
        case "init":
          token = data["token"] as String?;
          markNo = data["markNo"] as int?;
          break;
        case "manual_location":
          isSendingManualLocation = data["is_sending_manual_location"] as bool;
          manualLatitude = data["manual_latitude"] as double?;
          manualLongitude = data["manual_longitude"] as double?;
          break;
        default:
          debugPrint('Unknown data type: ${data["type"]}');
          break;
      }
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {}

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {}

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {}
}
