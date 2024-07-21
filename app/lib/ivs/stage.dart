import 'dart:js_interop';

import 'package:app/ivs/strategy.dart';

extension type Stage._(JSObject obj) implements JSObject {
  external Stage(String token, StageStrategy strategy);

  external JSPromise join();
  external void on(JSString event, JSFunction callback);
}
