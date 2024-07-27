part of 'session_cubit.dart';

sealed class SessionState extends Equatable {}

class PreJoinedSessionState extends SessionState {
  PreJoinedSessionState();

  @override
  List<Object?> get props => [];
}

class JoinedSessionState extends SessionState {
  JoinedSessionState({
    required this.localStream,
    this.participants = const [],
  });

  final IvsAVSource localStream;
  final List<SessionParticipant> participants;

  JoinedSessionState copyWith({
    IvsAVSource? localStream,
    List<SessionParticipant>? participants,
  }) =>
      JoinedSessionState(
        localStream: localStream ?? this.localStream,
        participants: participants ?? this.participants,
      );

  @override
  List<Object?> get props => [
        localStream,
        participants,
      ];
}

class SessionParticipant extends Equatable {
  SessionParticipant({
    required this.participantId,
    required this.participantName,
    required this.stream,
  });

  final String participantId;
  final String participantName;
  final IvsAVSource stream;

  @override
  List<Object?> get props => [participantId, stream];
}
