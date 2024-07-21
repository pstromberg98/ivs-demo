import 'dart:js_interop';

extension type Participant(JSObject obj) implements JSObject {
  external JSBoolean get isLocal;
  external JSString get id;
  external JSAny? get attributes;
  external JSString get grange;
}
