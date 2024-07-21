import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:app/app/app.dart';
import 'package:app/ivs/ivs.dart';
import 'package:app/ivs/local_stage_stream.dart';
import 'package:app/ivs/participant.dart';
import 'package:app/start/view/start_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this.sessionId,
    this.userId,
  }) : super(PreJoinedSessionState());

  final String sessionId;
  final String? userId;

  Future<void> join({
    required String username,
  }) async {
    if (state is PreJoinedSessionState && username.isNotEmpty) {
      final token = await _joinStage(
        sessionId: sessionId,
        userId: userId ?? getRandomUserId(),
        username: username,
      );

      final videoConstraintsObj = JSObject()
        ..setProperty(
          'width'.toJS,
          JSObject()..setProperty('max'.toJS, 1280.toJS),
        )
        ..setProperty(
          'height'.toJS,
          JSObject()..setProperty('min'.toJS, 720.toJS),
        );

      final devices = await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(
              audio: true.toJS, video: videoConstraintsObj))
          .toDart;

      final audioTrack = devices.getAudioTracks().toDart.firstOrNull;
      final videoTrack = devices.getVideoTracks().toDart.firstOrNull;
      final combinedStream = web.MediaStream();
      if (audioTrack != null) {
        combinedStream.addTrack(audioTrack);
      }

      if (videoTrack != null) {
        combinedStream.addTrack(videoTrack);
      }

      final audioStream =
          audioTrack != null ? LocalStageStream(audioTrack) : null;
      final videoStream =
          videoTrack != null ? LocalStageStream(videoTrack) : null;

      final ss = <web.MediaStream>[];
      final stage = Stage(
        token,
        StageStrategy(videoTrack: videoStream, audioTrack: audioStream),
      )
        ..on(
          StageEvents.STAGE_CONNECTION_STATE_CHANGED,
          (JSString s) {
            print('State change: $s');
          }.toJS,
        )
        ..on(
          StageEvents.STAGE_PARTICIPANT_STREAMS_ADDED,
          (Participant? participant, JSArray<StageStream>? streams) {
            print('Participant Local: ${participant?.isLocal.toDart}');
            if (participant?.isLocal.toDart ?? true) {
              return;
            }
            if (streams != null) {
              final tracks = streams.toDart
                  .where((s) => s.streamType.toDart == 'video')
                  .map((s) => s.mediaStreamTrack)
                  .toList();
              for (final track in tracks) {
                final mediaStream = web.MediaStream()..addTrack(track);
                ss.add(mediaStream);

                emit(
                  JoinedSessionState(
                    localStream: combinedStream,
                    remoteStreams: ss,
                  ),
                );
              }
            }
          }.toJS,
        );
      await stage.join().toDart;
      emit(
        JoinedSessionState(
          localStream: combinedStream,
          remoteStreams: [],
        ),
      );
    }
  }

  Future<String> _joinStage({
    required String sessionId,
    required String userId,
    required String username,
  }) async {
    final response = await http.post(
      Uri.parse('$API_URL/join'),
      body: jsonEncode({
        'sessionId': sessionId,
        'userId': userId,
        'attributes': {
          'username': username,
        },
      }),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final stageJson = json['stage'] as Map<String, dynamic>;
    final tokenJson = stageJson['token'] as Map<String, dynamic>;
    final token = tokenJson['token'] as String;
    return token;
  }
}
