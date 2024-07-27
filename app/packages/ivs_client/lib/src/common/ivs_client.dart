import 'package:flutter/foundation.dart';
import 'package:ivs_client/src/common/models/models.dart';
import 'package:ivs_client/src/web/web_ivs_client.dart';

/// {@template ivs_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
abstract class IvsClient {
  static IvsClient create() {
    if (kIsWeb) {
      return WebIvsClient();
    } else {
      // eventually this will return a client that utilizes platform channels
      // to communicate with an underlying native moblie plugin
      throw UnimplementedError();
    }
  }

  Future<IvsStage> stage(String token);
  Future<bool> requestAVPermissions();
  // Future<bool> requestAVPermissions() {}

  // Future<List<IvsDevice>> obtainDevices() async {
  //   final videoConstraintsObj = JSObject()
  //     ..setProperty(
  //       'width'.toJS,
  //       JSObject()..setProperty('max'.toJS, 1280.toJS),
  //     )
  //     ..setProperty(
  //       'height'.toJS,
  //       JSObject()..setProperty('min'.toJS, 720.toJS),
  //     );

  //   final webDevice = await web.window.navigator.mediaDevices
  //       .getUserMedia(
  //         web.MediaStreamConstraints(
  //           audio: true.toJS,
  //           video: videoConstraintsObj,
  //         ),
  //       )
  //       .toDart;
  //   final ivsDevice = IvsDevice(id: webDevice.id);

  //   return [ivsDevice];
  // }
}
