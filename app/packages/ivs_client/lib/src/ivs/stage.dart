import 'dart:js_interop';

import 'package:ivs_client/src/ivs/ivs.dart';

extension type Stage._(JSObject obj) implements JSObject {
  external Stage(String token, StageStrategy strategy);

  external JSPromise join();
  external JSPromise leave();

  external void on(JSString event, JSFunction callback);
}
