import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

int lastId = 0;

int _getNextId() {
  return lastId++;
}

typedef DimensionCallback = void Function(int width, int height);

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    required this.source,
    this.onDimensionChange,
    super.key,
  });

  final web.MediaStream source;
  final DimensionCallback? onDimensionChange;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  int id = _getNextId();

  late final web.HTMLVideoElement videoElement;

  @override
  void initState() {
    videoElement = web.HTMLVideoElement()
      ..id = 'video-$id'
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..srcObject = widget.source
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
