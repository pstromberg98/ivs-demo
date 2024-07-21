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
    required this.remoteStreams,
  });

  final web.MediaStream localStream;
  final List<web.MediaStream> remoteStreams;

  @override
  List<Object?> get props => [localStream, remoteStreams];
}
