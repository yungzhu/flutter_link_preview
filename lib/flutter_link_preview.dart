library flutter_link_preview;

import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';

part 'web_analyzer.dart';

/// Link Preview Widget
class FlutterLinkPreview extends StatefulWidget {
  const FlutterLinkPreview({
    Key key,
    @required this.url,
    this.cache = const Duration(hours: 1),
    this.builder,
    this.titleStyle,
    this.bodyStyle,
    this.showMultimedia = true,
  }) : super(key: key);

  /// Web address, HTTP and HTTPS support
  final String url;

  /// Cache result time, default cache 1 hour
  final Duration cache;

  /// Customized rendering methods
  final Widget Function(InfoBase info) builder;

  /// Title style
  final TextStyle titleStyle;

  /// Content style
  final TextStyle bodyStyle;

  /// Show image or video
  final bool showMultimedia;

  @override
  _FlutterLinkPreviewState createState() => _FlutterLinkPreviewState();
}

class _FlutterLinkPreviewState extends State<FlutterLinkPreview> {
  String _url;
  InfoBase _info;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _url = widget.url.trim();
    if (_url.startsWith("http")) {
      _info = await WebAnalyzer.getInfo(
        _url,
        cache: widget.cache,
        multimedia: widget.showMultimedia,
      );
      if (mounted) setState(() {});
    } else {
      print("Links don't start with http or https from : $_url");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder(_info);
    }

    if (_info == null || _info is VideoInfo) {
      return const SizedBox();
    }

    if (_info is ImageInfo) {
      return CachedNetworkImage(
        imageUrl: (_info as ImageInfo).url,
        fit: BoxFit.contain,
      );
    }

    final WebInfo info = _info;
    if (!WebAnalyzer.isNotEmpty(info.title)) return const SizedBox();
    final bool hasDescription = WebAnalyzer.isNotEmpty(info.description);
    final Color iconColor = widget.titleStyle?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: info.icon ?? "",
              fit: BoxFit.contain,
              width: 30,
              height: 30,
              errorWidget: (_, __, ___) =>
                  Icon(Icons.link, size: 30, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                info.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: widget.titleStyle,
              ),
            ),
          ],
        ),
        if (hasDescription) const SizedBox(height: 8),
        if (hasDescription)
          Text(
            info.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: widget.bodyStyle,
          ),
      ],
    );
  }
}
