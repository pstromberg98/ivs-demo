import 'package:app/session/cubit/session_cubit.dart';
import 'package:app/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;

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
  Widget build(BuildContext context) {
    // set desired items in row
    // find per item width = width / desired columns
    // find per item height = height / ((items / desired columns).round())

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
                  context
                      .read<SessionCubit>()
                      .join(username: _usernameController.text);
                },
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      JoinedSessionState() => LayoutBuilder(
          builder: (context, constraints) {
            final itemCount = state.remoteStreams.length + 1;
            final desiredColumns =
                itemCount == 1 ? 1 : (itemCount / 4).floor() + 2;
            final width = constraints.biggest.width;
            final height = constraints.biggest.height;

            final perItemWidth = width / desiredColumns;
            final perItemHeight = height / (itemCount / desiredColumns).ceil();

            return GridView.custom(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: perItemWidth,
                mainAxisExtent: perItemHeight,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              childrenDelegate: SliverChildListDelegate.fixed(
                [
                  _Video(
                    source: state.localStream,
                  ),
                  ...state.remoteStreams.map((s) => _Video(source: s)),
                ],
              ),
            );
          },
        ),
    };

    return widget;
  }
}

class _VideoDecorations extends StatelessWidget {
  const _VideoDecorations({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: Text(
                    'test',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Video extends StatefulWidget {
  const _Video({
    required this.source,
  });

  final web.MediaStream source;

  @override
  State<_Video> createState() => _VideoState();
}

class _VideoState extends State<_Video> {
  double width = 0;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: LayoutBuilder(
    //     builder: (context, c) {
    //       return LayoutBuilder(
    //         builder: (context, constraints) {
    //           print(constraints);
    //           return Container(
    //             width: 10,
    //             height: 10,
    //             color: Colors.green,
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );
    return Container(
      color: Colors.black,
      child: FittedBox(
        // clipBehavior: Clip.hardEdge,
        // fit: BoxFit.cover,
        child: _VideoDecorations(
          child: SizedBox(
            width: width,
            height: height,
            child: VideoPlayer(
              source: widget.source,
              onDimensionChange: (width, height) {
                setState(() {
                  this.width = width.toDouble();
                  this.height = height.toDouble();
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
