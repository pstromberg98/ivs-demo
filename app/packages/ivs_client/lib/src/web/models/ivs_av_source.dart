import 'package:ivs_client/src/common/models/models.dart';
import 'package:web/web.dart' as web;

class WebIvsAVSource implements IvsAVSource {
  WebIvsAVSource(this.mediaStream);

  final web.MediaStream mediaStream;
}
