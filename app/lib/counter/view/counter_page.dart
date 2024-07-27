import 'package:app/counter/cubit/counter_cubit.dart';
import 'package:app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const API_URL = 'https://z0dkhotaok.execute-api.us-east-1.amazonaws.com/prod';

// {
//     "sessionId": "a6c22206-744f-4780-ade3-6313456ab905",
//     "stage": {
//         "id": "arn:aws:ivs:us-east-1:910807072694:stage/tP1gdHC4bmWN",
//         "token": {
//             "attributes": {
//                 "username": "8"
//             },
//             "duration": 1440,
//             "participantId": "OvRDuLZ7RXfx",
//             "token": "eyJhbGciOiJLTVMiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE3MjE2MjQ1MjksImlhdCI6MTcyMTUzODEyOSwianRpIjoiT3ZSRHVMWjdSWGZ4IiwicmVzb3VyY2UiOiJhcm46YXdzOml2czp1cy1lYXN0LTE6OTEwODA3MDcyNjk0OnN0YWdlL3RQMWdkSEM0Ym1XTiIsInRvcGljIjoidFAxZ2RIQzRibVdOIiwiZXZlbnRzX3VybCI6IndzczovL2dsb2JhbC5ldmVudHMubGl2ZS12aWRlby5uZXQiLCJ3aGlwX3VybCI6Imh0dHBzOi8vN2JmMDQ1ZjI5NjE3Lmdsb2JhbC1ibS53aGlwLmxpdmUtdmlkZW8ubmV0IiwidXNlcl9pZCI6IjIzIiwiYXR0cmlidXRlcyI6eyJ1c2VybmFtZSI6IjgifSwiY2FwYWJpbGl0aWVzIjp7ImFsbG93X3B1Ymxpc2giOnRydWUsImFsbG93X3N1YnNjcmliZSI6dHJ1ZX0sInZlcnNpb24iOiIwLjAifQ.MGQCMAKT_cn53PHiPfdt7ut8uTkFc8wxAs0HHGtSmJTxmHMOLuJOJnQoY2YTCqDKxv1kfAIwUbgWBzqPkAJfA0lUDhQ55TOweOT0Xa5KwuCPsTSZpc2m4F87Xiq8RKXPGJk3-xj5",
//             "userId": "23"
//         }
//     },
//     "expiration": "2024-07-22T05:02:08.961Z"
// }

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  void initState() {
    // final username = getRandomUserId();
    // createStage(
    //   userId: userId,
    //   username: username,
    // ).then((stage) async {
    //   final token = await joinStage(
    //     sessionId: stage.sessionId,
    //     userId: userId,
    //     username: username,
    //   );
    //   print('Token: ${token}');
    //   final stageStrategy = StageStrategy();
    //   final s = Stage(token, stageStrategy)
    //     ..on(
    //       'stageConnectionStateChanged'.toJS,
    //       (JSAny state) {
    //         print('new state: $state');
    //       }.toJS,
    //     )
    //     ..join();
    // });
    super.initState();
  }

  // Future<String> joinStage({
  //   required String sessionId,
  //   required String userId,
  //   required String username,
  // }) async {
  //   final response = await http.post(
  //     Uri.parse('$API_URL/join'),
  //     body: jsonEncode({
  //       'sessionId': sessionId,
  //       'userId': userId,
  //       'attributes': {
  //         'username': username,
  //       },
  //     }),
  //   );

  //   final json = jsonDecode(response.body) as Map<String, dynamic>;
  //   final stageJson = json['stage'] as Map<String, dynamic>;
  //   final tokenJson = stageJson['token'] as Map<String, dynamic>;
  //   final token = tokenJson['token'] as String;
  //   return token;
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.counterAppBarTitle)),
      body: const Center(child: CounterText()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = context.select((CounterCubit cubit) => cubit.state);
    return Text('$count', style: theme.textTheme.displayLarge);
  }
}
