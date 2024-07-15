import { EventBridgeEvent } from "aws-lambda";
import { hasParticipants } from '../src/hasParticipants';
import { deleteSessionAndResources } from "delete";

async function unpublishHandler(
    event: EventBridgeEvent<'IVS Stage Update', any>,
) {
    const shouldDelete = !await hasParticipants(event.resources[0], event.detail.session_id);
    if (shouldDelete) {
        console.log('Deleting session....')
        deleteSessionAndResources(event.detail.session_id);
    } else {
        console.log('shouldnt delete...');
    }
}

export { unpublishHandler };