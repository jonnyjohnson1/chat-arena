import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';

Future<bool> isDesktopPlatform({bool includeIosAppOnMac = false}) async {
  if (!includeIosAppOnMac) {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } else {
    return kIsWeb ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        await IsIosAppOnMac().isiOSAppOnMac();
  }
}
