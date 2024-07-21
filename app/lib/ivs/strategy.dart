import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:app/ivs/local_stage_stream.dart';
// import 'package:web/web.dart' as web;

extension type StageStrategy._(JSObject obj) implements JSObject {
  StageStrategy({
    LocalStageStream? audioTrack,
    LocalStageStream? videoTrack,
  }) : obj = JSObject() {
    obj
      ..setProperty('stageStreamsToPublish'.toJS, _stageStreamsToPublish.toJS)
      ..setProperty(
        'shouldPublishParticipant'.toJS,
        _shouldPublishParticipant.toJS,
      )
      ..setProperty(
        'shouldSubscribeToParticipant'.toJS,
        _shouldSubscribeToParticipant.toJS,
      )
      ..setProperty('audioTrack'.toJS, audioTrack)
      ..setProperty('videoTrack'.toJS, videoTrack);
  }
  void updateTracks(JSObject? audioTrack, JSObject? videoTrack) {
    obj
      ..setProperty('audioTrack'.toJS, audioTrack)
      ..setProperty('videoTrack'.toJS, videoTrack);
  }

  JSArray _stageStreamsToPublish() {
    return [
      obj.getProperty('audioTrack'.toJS),
      obj.getProperty('videoTrack'.toJS),
    ].toJS;
  }

  JSBoolean _shouldPublishParticipant(JSObject participant) {
    return true.toJS;
  }

  String _shouldSubscribeToParticipant(JSObject participant) {
    return 'audio_video';
  }
}
