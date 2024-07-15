import { participantCount } from "sdk/realtime";

async function hasParticipants(
    stageArn: string,
    sessionId: string,
) {
    const count = await participantCount(stageArn, sessionId);
    return count > 0;
}

export { hasParticipants }