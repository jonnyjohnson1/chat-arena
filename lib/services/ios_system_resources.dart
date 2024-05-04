import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SystemResources {
  final EventChannel eventModelDownloadSubsChannel =
      const EventChannel('event.SystemResources.Stream');

  StreamSubscription? systemResourcesSubscription;

  subscribeToSystemResourcesStream(dynamic _onEventCallback) async {
    try {
      systemResourcesSubscription = eventModelDownloadSubsChannel
          .receiveBroadcastStream()
          .listen(_onEventCallback, onError: _onError);
      return true;
    } on PlatformException catch (e) {
      throw ArgumentError('Unable to init stream: ${e.message}');
    } on MissingPluginException catch (e) {
      throw ErrorSummary('${e.message}');
    }
  }

  stopSystemResourcesStream() async {
    if (systemResourcesSubscription != null) {
      await systemResourcesSubscription!.cancel();
      systemResourcesSubscription = null;
    }
  }

  //

  String _onError(Object error) {
    return "Error producing generation";
  }

  Future<String> getModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    return info.model;
  }

  Future<bool> isIphone() async {
    print("isIphone");
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    print(deviceInfo);
    try {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      print(info);
      print(info.data);
      print(info.model);
      print("her");
      if (info.model != null) {
        print(info.model.runtimeType);
        if (info.model.toLowerCase().contains("iphone")) {
          return true;
        }
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }
}
