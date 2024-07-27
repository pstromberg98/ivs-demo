import 'dart:js_interop';

import 'package:ivs_client/src/web/ivs/ivs.dart';
import 'package:web/web.dart';

extension type LocalStageStream._(JSObject obj) implements StageStream {
  external LocalStageStream(MediaStreamTrack track);
}
