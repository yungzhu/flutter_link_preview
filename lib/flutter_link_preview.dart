library flutter_link_preview;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

part 'web_analyzer.dart';

/// Link Preview Widget
class FlutterLinkPreview extends StatefulWidget {
  const FlutterLinkPreview({
    Key key,
    @required this.url,
    this.cache = const Duration(hours: 24),
    this.builder,
    this.titleStyle,
    this.bodyStyle,
    this.showMultimedia = true,
    this.useMultithread = false,
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

  /// Whether to use multi-threaded analysis of web pages
  final bool useMultithread;

  @override
  _FlutterLinkPreviewState createState() => _FlutterLinkPreviewState();
}

class _FlutterLinkPreviewState extends State<FlutterLinkPreview> {
  String _url;
  InfoBase _info;

  @override
  void initState() {
    _url = widget.url.trim();
    _info = WebAnalyzer.getInfoFromCache(_url);
    if (_info == null) _getInfo();
    super.initState();
  }

  Future<void> _getInfo() async {
    if (_url.startsWith("http")) {
      _info = await WebAnalyzer.getInfo(
        _url,
        cache: widget.cache,
        multimedia: widget.showMultimedia,
        useMultithread: widget.useMultithread,
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

    if (_info == null) return const SizedBox();

    if (_info is WebImageInfo) {
      return Image.network(
        (_info as WebImageInfo).image,
        fit: BoxFit.contain,
      );
    }

    final WebInfo info = _info;
    if (!WebAnalyzer.isNotEmpty(info.title)) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Image.network(
              info.icon ?? "",
              fit: BoxFit.contain,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.link, size: 30, color: widget.titleStyle?.color),
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
        if (WebAnalyzer.isNotEmpty(info.description)) ...[
          const SizedBox(height: 8),
          Text(
            info.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: widget.bodyStyle,
          ),
        ],
      ],
    );
  }
}
