import 'package:package_info/package_info.dart';

class AppRuntimeSettings {
  static final AppRuntimeSettings _singleton = AppRuntimeSettings._internal();

  factory AppRuntimeSettings() => _singleton;

  AppRuntimeSettings._internal() {
    _getPackageInfo();
  }

  String get version => _packageInfo?.version ?? '';

  PackageInfo? _packageInfo;

  void _getPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
