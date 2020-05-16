library flutter_link_preview;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

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
  }) : super(key: key);

  /// Web address, HTTP and HTTPS support
  final String url;

  /// Cache result time, default cache 1 hour
  final Duration cache;

  /// Customized rendering methods
  final Widget Function(WebInfo info) builder;

  /// Title style
  final TextStyle titleStyle;

  /// Content style
  final TextStyle bodyStyle;

  @override
  _FlutterLinkPreviewState createState() => _FlutterLinkPreviewState();
}

class _FlutterLinkPreviewState extends State<FlutterLinkPreview> {
  String _url;
  WebInfo _info;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    _url = widget.url.trim();
    if (_url.startsWith("http")) {
      var url = _url.replaceFirst("https", "http");
      _info = await WebAnalyzer.getInfo(url, widget.cache);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder(_info);
    }

    if (_info == null || !WebAnalyzer.isNotEmpty(_info.icon)) {
      return const SizedBox();
    }

    final bool hasDescription = WebAnalyzer.isNotEmpty(_info.description);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.network(
              _info.icon,
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _info.title,
                overflow: TextOverflow.ellipsis,
                style: widget.titleStyle,
              ),
            ),
          ],
        ),
        if (hasDescription) const SizedBox(height: 8),
        if (hasDescription)
          Text(
            _info.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: widget.bodyStyle,
          ),
      ],
    );
  }
}
