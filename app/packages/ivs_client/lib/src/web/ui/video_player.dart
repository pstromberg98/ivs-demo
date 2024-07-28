import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:ivs_client/src/common/ui/video_player.dart';
import 'package:ivs_client/src/web/models/models.dart';
import 'package:web/web.dart' as web;

int _lastId = 0;

int _getNextId() {
  return _lastId++;
}

class WebIvsAVSourcePlayer extends StatefulWidget {
  const WebIvsAVSourcePlayer({
    super.key,
    required this.source,
    this.onDimensionChange,
  });

  final WebIvsAVSource source;
  final DimensionCallback? onDimensionChange;

  @override
  State<WebIvsAVSourcePlayer> createState() => _WebIvsAVSourcePlayerState();
}

class _WebIvsAVSourcePlayerState extends State<WebIvsAVSourcePlayer> {
  int id = _getNextId();

  late final web.HTMLVideoElement videoElement;

  @override
  void initState() {
    final source = widget.source as WebIvsAVSource;
    videoElement = web.HTMLVideoElement()
      ..id = 'video-$id'
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..srcObject = source.mediaStream
      ..play();

    ui_web.platformViewRegistry.registerViewFactory(
      'video-$id',
      (int viewId) => videoElement,
    );

    // Future.delayed(Duration(seconds: 4)).then((_) {
    //   print(videoElement.videoHeight);
    //   print(videoElement.videoWidth);
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    videoElement.onLoadedData.listen((data) {
      final logicalWidth = videoElement.videoWidth / devicePixelRatio;
      final logicalHeight = videoElement.videoHeight / devicePixelRatio;
      widget.onDimensionChange?.call(
        logicalWidth.round(),
        logicalHeight.round(),
      );
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'video-$id',
    );
  }
}
