import 'dart:convert';
import 'dart:math';

import 'package:app/api_models/stage_response_data.dart';
import 'package:app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

String getRandomUserId() {
  return Random().nextInt(34).toString();
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: StartView(),
    );
  }
}

class StartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'VGV Real-time',
            style: TextStyle(
              fontSize: 35,
              // color: Colors.white,
            ),
          ),
          OutlinedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return const _SessionDialog();
                },
              );
            },
            child: const Text(
              'Create Session',
            ),
          )
        ],
      ),
    );
  }
}

class _SessionDialog extends StatefulWidget {
  const _SessionDialog();

  @override
  State<_SessionDialog> createState() => __SessionDialogState();
}

class __SessionDialogState extends State<_SessionDialog> {
  final TextEditingController _usernameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Session'),
      content: TextField(
        controller: _usernameTextController,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final router = GoRouter.of(context);
            final username = _usernameTextController.text;
            final userId = getRandomUserId();
            final stage = await createStage(
              userId: userId,
              username: username,
            );
            router.go(
              '/session/${stage.sessionId}',
              extra: userId,
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<StageResponseData> createStage({
    required String userId,
    required String username,
  }) async {
    final response = await http.post(
      Uri.parse('$API_URL/create'),
      body: jsonEncode({
        'userId': userId,
        'attributes': {
          'username': username,
        },
      }),
    );

    final json = jsonDecode(response.body);
    final stageJson = json['stage'] as Map<String, dynamic>;
    final tokenJson = stageJson['token'] as Map<String, dynamic>;
    return StageResponseData(
      sessionId: json['sessionId'] as String,
      stage: StageData(
        id: stageJson['id'] as String,
        token: StageTokenData(
          participantId: tokenJson['participantId'] as String,
          token: tokenJson['token'] as String,
        ),
      ),
    );
  }
}
