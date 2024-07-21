class StageResponseData {
  StageResponseData({
    required this.sessionId,
    required this.stage,
  });

  final String sessionId;
  final StageData stage;
}

class StageData {
  StageData({
    required this.id,
    required this.token,
  });

  final String id;
  final StageTokenData token;
}

class StageTokenData {
  StageTokenData({
    required this.participantId,
    required this.token,
  });

  final String participantId;
  final String token;
}
