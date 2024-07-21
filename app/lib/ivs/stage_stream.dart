import 'dart:js_interop';
import 'package:web/web.dart' as web;

extension type StageStream._(JSObject obj) implements JSObject {
  external StageStream(web.MediaStreamTrack track);

  external JSString get id;
  external JSBoolean get isMuted;
  external web.MediaStreamTrack mediaStreamTrack;
  external JSString get streamType;
}
