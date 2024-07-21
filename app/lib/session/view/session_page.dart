import 'package:app/session/cubit/session_cubit.dart';
import 'package:app/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({
    required this.sessionId,
    required this.userId,
    super.key,
  });

  final String sessionId;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SessionCubit(
          sessionId: sessionId,
        ),
        child: SessionView(
          sessionId: sessionId,
        ),
      ),
    );
  }
}

class SessionView extends StatefulWidget {
  const SessionView({
    required this.sessionId,
    super.key,
  });

  final String sessionId;

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    print('Session Id: ${widget.sessionId}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SessionCubit>().state;
    final widget = switch (state) {
      PreJoinedSessionState() => SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter username',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _usernameController,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  final cubit = context.read<SessionCubit>();
                  cubit.join(username: _usernameController.text);
                },
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      JoinedSessionState() => ListView(
          children: [
            SizedBox(
              height: 400,
              width: 400,
              child: VideoPlayer(
                source: state.localStream,
              ),
            ),
            ...state.remoteStreams.map(
              (s) => SizedBox(
                height: 400,
                width: 400,
                child: VideoPlayer(source: s),
              ),
            ),
          ],
        ),
      _ => Text('No associated widget to state'),
    };

    return BlocListener<SessionCubit, SessionState>(
      listener: (context, state) {},
      listenWhen: (previous, next) =>
          previous.runtimeType != next.runtimeType &&
          next is JoinedSessionState,
      child: widget,
    );
  }
}
