library flutter_link_preview;

import 'package:flutter/material.dart';
import 'web_parser.dart';

class FlutterLinkPreview extends StatefulWidget {
  const FlutterLinkPreview(
      {Key key, @required this.url, this.cache, this.builder})
      : super(key: key);
  final String url;
  final Duration cache;
  final Widget Function(WebInfo info) builder;

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
      _url = _url.replaceFirst("https", "http");
      _info = await WebParser.getData(_url, widget.cache);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder(_info);
    }

    if (_info == null || !WebParser.isNotEmpty(_info.icon)) {
      return const SizedBox();
    }

    final bool hasDescription = WebParser.isNotEmpty(_info.description);
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
          ),
      ],
    );
  }
}
