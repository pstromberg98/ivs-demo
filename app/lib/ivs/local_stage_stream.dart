import 'dart:js_interop';

import 'package:app/ivs/ivs.dart';
import 'package:web/web.dart';

extension type LocalStageStream._(JSObject obj) implements StageStream {
  external LocalStageStream(MediaStreamTrack track);
}
