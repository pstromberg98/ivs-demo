import 'dart:js_interop';

import 'package:ivs_client/src/ivs/ivs.dart';
import 'package:web/web.dart';

extension type LocalStageStream._(JSObject obj) implements StageStream {
  external LocalStageStream(MediaStreamTrack track);
}
