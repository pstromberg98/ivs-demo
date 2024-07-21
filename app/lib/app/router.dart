import 'package:app/session/view/session_page.dart';
import 'package:app/start/view/start_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const StartPage(),
    ),
    GoRoute(
      path: '/session/:id',
      builder: (context, state) => SessionPage(
        sessionId: state.pathParameters['id']!,
        userId: state.extra as String?,
      ),
    ),
  ],
);
