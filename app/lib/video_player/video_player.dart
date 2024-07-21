import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

int lastId = 0;

int _getNextId() {
  return lastId++;
}

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    required this.source,
    super.key,
  });

  final web.MediaStream source;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  int id = _getNextId();

  @override
  void initState() {
    final videoElement = web.HTMLVideoElement()
      ..id = 'video-$id'
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..srcObject = widget.source;

    videoElement.play();

    ui_web.platformViewRegistry.registerViewFactory(
      'video-$id',
      (int viewId) => videoElement,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'video-$id',
    );
  }
}
