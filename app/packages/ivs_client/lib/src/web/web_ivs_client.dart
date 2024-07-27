import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';

import 'package:ivs_client/src/common/ivs_client.dart';
import 'package:ivs_client/src/common/models/models.dart';
import 'package:ivs_client/src/web/ivs/ivs.dart' as ivs_web;
import 'package:ivs_client/src/web/models/models.dart';
import 'package:web/web.dart' as web;

/// {@template ivs_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class WebIvsClient implements IvsClient {
  Future<IvsStage> stage(String token) async {
    final videoConstraintsObj = JSObject()
      ..setProperty(
        'width'.toJS,
        JSObject()..setProperty('max'.toJS, 1280.toJS),
      )
      ..setProperty(
        'height'.toJS,
        JSObject()..setProperty('min'.toJS, 720.toJS),
      );

    final webDevice = await web.window.navigator.mediaDevices
        .getUserMedia(
          web.MediaStreamConstraints(
            audio: true.toJS,
            video: videoConstraintsObj,
          ),
        )
        .toDart;

    final audioTrack = webDevice.getAudioTracks().toDart.firstOrNull;
    final videoTrack = webDevice.getVideoTracks().toDart.firstOrNull;
    final combinedStream = web.MediaStream();
    if (audioTrack != null) {
      combinedStream.addTrack(audioTrack);
    }

    if (videoTrack != null) {
      combinedStream.addTrack(videoTrack);
    }

    final audioStream =
        audioTrack != null ? ivs_web.LocalStageStream(audioTrack) : null;
    final videoStream =
        videoTrack != null ? ivs_web.LocalStageStream(videoTrack) : null;

    final stage = ivs_web.Stage(
      token,
      ivs_web.StageStrategy(
        videoTrack: videoStream,
        audioTrack: audioStream,
      ),
    );

    final ivsStage = WebIvsStage(
      localSource: WebIvsAVSource(combinedStream),
      stage: stage,
    );

    return ivsStage;
  }

  @override
  Future<bool> requestAVPermissions() {
    throw UnimplementedError();
  }
}
