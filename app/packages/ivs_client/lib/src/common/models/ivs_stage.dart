import 'dart:js_interop';

import 'package:ivs_client/src/web/ivs/ivs.dart' as ivs;
import 'package:ivs_client/src/web/ivs/participant.dart';
import 'package:ivs_client/src/common/models/models.dart';
import 'package:web/web.dart' as web;

typedef ParticipantJoinedCallback = void Function(IvsParticipant? participant);
typedef ParticipantLeftCallback = void Function(IvsParticipant? participant);
typedef ParticipantStreamsAddedCallback = void Function(
  IvsParticipant? participant,
  IvsAVSource? source,
);

abstract class IvsStage {
  IvsAVSource get localSource;

  Future<void> join();

  void onParticipantJoined(ParticipantJoinedCallback callback);

  void onParticipantLeft(ParticipantLeftCallback callback);

  void onParticipantStreamsAdded(ParticipantStreamsAddedCallback callback);
}
