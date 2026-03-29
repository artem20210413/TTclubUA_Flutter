import 'package:package_info_plus/package_info_plus.dart';

class HardConfig {
  static String version = "unknown";

  static Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = "${packageInfo.version}+${packageInfo.buildNumber}";
  }
}
