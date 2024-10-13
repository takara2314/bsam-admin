import 'package:bsam_admin/utils/random.dart';

String createManagerDeviceId() {
  return 'manager-${getRandomInt(10000, 99999)}';
}
