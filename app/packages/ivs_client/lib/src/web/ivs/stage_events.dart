import 'dart:js_interop';

extension type StageEvents._(JSObject obj) implements JSObject {
  external static JSString get STAGE_CONNECTION_STATE_CHANGED;
  external static JSString get STAGE_PARTICIPANT_JOINED;
  external static JSString get STAGE_PARTICIPANT_LEFT;
  external static JSString get STAGE_PARTICIPANT_PUBLISH_STATE_CHANGED;
  external static JSString get STAGE_PARTICIPANT_SUBSCRIBE_STATE_CHANGED;
  external static JSString get STAGE_PARTICIPANT_STREAMS_ADDED;
  external static JSString get STAGE_PARTICIPANT_STREAMS_REMOVED;
  external static JSString get STAGE_STREAM_MUTE_CHANGED;
}
