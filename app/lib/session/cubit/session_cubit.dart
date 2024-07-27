import 'dart:convert';

import 'package:app/app/app.dart';
import 'package:app/start/view/start_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ivs_client/ivs_client.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this.sessionId,
    this.userId,
  }) : super(PreJoinedSessionState());

  final String sessionId;
  final String? userId;
  final IvsClient _ivsClient = IvsClient.create();

  Future<void> join({
    required String username,
  }) async {
    if (state is PreJoinedSessionState && username.isNotEmpty) {
      final token = await _joinStage(
        sessionId: sessionId,
        userId: userId ?? getRandomUserId(),
        username: username,
      );
      final stage = await _ivsClient.stage(token);
      stage
        ..onParticipantStreamsAdded((participant, source) {
          if (participant?.isLocal ?? true) {
            return;
          }

          if (participant != null && state is JoinedSessionState) {
            final joinedState = state as JoinedSessionState;
            const name = 'unknown';
            // final attributes = participant.attributes;
            // if (attributes != null && attributes.isA<JSObject>()) {
            //   name = ((attributes as JSObject).getProperty('username'.toJS)
            //               as JSString?)
            //           ?.toDart ??
            //       'unknown';
            // }

            emit(
              joinedState.copyWith(
                participants: [
                  ...joinedState.participants,
                  SessionParticipant(
                    participantId: participant.id,
                    participantName: name,
                    stream: source!,
                  ),
                ],
              ),
            );
          }
        })
        ..onParticipantLeft(
          (participant) {
            if (participant != null && state is JoinedSessionState) {
              final joinedState = state as JoinedSessionState;
              emit(
                joinedState.copyWith(
                  participants: joinedState.participants
                      .where((p) => p.participantId != participant.id)
                      .toList(),
                ),
              );
            }
          },
        );

      await stage.join();

      emit(
        JoinedSessionState(
          localStream: stage.localSource,
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
