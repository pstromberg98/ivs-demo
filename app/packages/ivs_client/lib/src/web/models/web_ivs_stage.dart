import 'dart:js_interop';

import 'package:ivs_client/src/common/models/models.dart';
import 'package:ivs_client/src/web/ivs/ivs.dart' as ivs;
import 'package:ivs_client/src/web/ivs/participant.dart';
import 'package:ivs_client/src/web/models/ivs_av_source.dart';
import 'package:web/web.dart' as web;

typedef ParticipantJoinedCallback = void Function(IvsParticipant? participant);
typedef ParticipantLeftCallback = void Function(IvsParticipant? participant);
typedef ParticipantStreamsAddedCallback = void Function(
  IvsParticipant? participant,
  IvsAVSource? source,
);

class WebIvsStage implements IvsStage {
  WebIvsStage({
    required this.localSource,
    required ivs.Stage stage,
  }) : _underlyingStage = stage;

  IvsAVSource localSource;
  ivs.Stage _underlyingStage;

  Future<void> join() async {
    await _underlyingStage.join().toDart;
  }

  void onParticipantStreamsAdded(ParticipantStreamsAddedCallback callback) {
    _underlyingStage.on(
      ivs.StageEvents.STAGE_PARTICIPANT_STREAMS_ADDED,
      (Participant? participant, JSArray<ivs.StageStream>? streams) {
        if (participant != null && streams != null) {
          var attributes = {};
          if (participant.attributes?.isA<JSObject>() ?? false) {
            attributes = JSObjectX(
              participant.attributes! as JSObject,
            ).toDart;
          }
          final mediaStream = web.MediaStream();
          for (final stream in streams.toDart) {
            mediaStream.addTrack(stream.mediaStreamTrack);
          }
          callback(
            IvsParticipant(
              id: participant.id.toDart,
              isLocal: participant.isLocal.toDart,
              attributes: attributes,
            ),
            WebIvsAVSource(mediaStream),
          );
        } else {
          callback(null, null);
        }
      }.toJS,
    );
  }

  void onParticipantJoined(ParticipantJoinedCallback callback) {
    _underlyingStage.on(
      ivs.StageEvents.STAGE_PARTICIPANT_JOINED,
      (Participant? participant) {}.toJS,
    );
  }

  void onParticipantLeft(ParticipantLeftCallback callback) {
    _underlyingStage.on(
      ivs.StageEvents.STAGE_PARTICIPANT_LEFT,
      (Participant? participant) {
        if (participant != null) {
          // final attributes = JSObjectX(participant.obj).toDart();
          callback(
            IvsParticipant(
              id: participant.id.toDart,
              isLocal: participant.isLocal.toDart,
              attributes: Map(),
            ),
          );
        } else {
          callback(null);
        }
      }.toJS,
    );
  }
}

extension type Object(JSObject _) implements JSObject {
  external static JSArray<JSAny> keys(JSObject obj);
}

extension type JSObjectX(JSObject _) implements JSObject {
  external JSAny? operator [](String value);

  Map get toDart {
    Map obj = {};
    for (final key in Object.keys(_).toDart) {
      if (key is JSString) {
        final value = this[key.toDart];
        if (value != null && value.isA<JSString>()) {
          obj[key] = (value as JSString).toDart;
        }
      }
    }

    return obj;
  }
}
