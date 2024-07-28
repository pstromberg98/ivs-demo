import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ivs_client/src/common/common.dart';
import 'package:ivs_client/src/web/models/models.dart';
import 'package:ivs_client/src/web/ui/video_player.dart';

typedef DimensionCallback = void Function(int width, int height);

class IvsAVSourcePlayer extends StatelessWidget {
  const IvsAVSourcePlayer({
    super.key,
    required this.source,
    this.onDimensionChange,
  });

  final IvsAVSource source;
  final DimensionCallback? onDimensionChange;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebIvsAVSourcePlayer(
        source: source as WebIvsAVSource,
        onDimensionChange: onDimensionChange,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
