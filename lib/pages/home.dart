import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie_admin/providers/androidId.dart';
import 'package:sailing_assist_mie_admin/providers/deviceName.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocationAllowed = useState<bool>(false);
    final androidId = ref.watch(androidIdProvider.notifier);
    final deviceName = ref.watch(deviceNameProvider.notifier);

    useEffect(() {
      () async {
        var status = await Permission.location.status;

        if (status == PermissionStatus.denied) {
          status = await Permission.location.request();
        }

        isLocationAllowed.value = status.isGranted;

        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        androidId.state = androidInfo.androidId.toString();
        deviceName.state = androidInfo.brand.toString();
      }();
    }, const []);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Text(
                    'Sailing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(0, 42, 149, 1),
                      fontSize: 60.h
                    )
                  ),
                  Text(
                    'Assist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(0, 42, 149, 1),
                      fontSize: 60.h
                    )
                  ),
                  Text(
                    'Mie',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(0, 42, 149, 1),
                      fontSize: 60.h
                    )
                  ),
                  Text(
                    '本部用',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 248, 34, 6),
                      fontSize: 25.h
                    )
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              margin: EdgeInsets.only(top: 70.h, bottom: 70.h)
            ),
            SizedBox(
              child: Column(
                children: [
                  ElevatedButton(
                    child: Text(
                      'マークを設置',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () => context.go('/place/races'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(0, 98, 104, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      minimumSize: Size(280.w, 60.h)
                    )
                  ),
                  ElevatedButton(
                    child: Text(
                      'レースを設定',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () => context.go('/manage/races'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(0, 98, 104, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      minimumSize: Size(280.w, 60.h)
                    )
                  ),
                  ElevatedButton(
                    child: Text(
                      'レースを企画する',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () => context.go('/create'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(0, 98, 104, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      minimumSize: Size(280.w, 60.h)
                    )
                  ),
                  TextButton(
                    child: Text(
                      '設定する',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () => context.go('/settings')
                  ),
                  Visibility(
                    visible: !isLocationAllowed.value,
                    child: const Text(
                      '位置情報が有効になっていません！',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      )
                    )
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              height: 350
            )
          ]
        )
      ),
      backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
    );
  }
}
