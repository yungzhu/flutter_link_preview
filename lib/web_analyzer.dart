part of flutter_link_preview;

abstract class InfoBase {
  late DateTime _timeout;
}

/// Web Information
class WebInfo extends InfoBase {
  final String? title;
  final String? icon;
  final String? description;
  final String? image;
  final String? redirectUrl;

  WebInfo({
    this.title,
    this.icon,
    this.description,
    this.image,
    this.redirectUrl,
  });
}

/// Image Information
class WebImageInfo extends InfoBase {
  final String? image;

  WebImageInfo({required this.image});
}

/// Video Information
class WebVideoInfo extends WebImageInfo {
  WebVideoInfo({String? image}) : super(image: image);
}

/// Web analyzer
class WebAnalyzer {
  static final Map<String, InfoBase> _map = {};
  static final RegExp _bodyReg =
      RegExp(r"<body[^>]*>([\s\S]*?)<\/body>", caseSensitive: false);
  static final RegExp _htmlReg = RegExp(
      r"(<head[^>]*>([\s\S]*?)<\/head>)|(<script[^>]*>([\s\S]*?)<\/script>)|(<style[^>]*>([\s\S]*?)<\/style>)|(<[^>]+>)|(<link[^>]*>([\s\S]*?)<\/link>)|(<[^>]+>)",
      caseSensitive: false);
  static final RegExp _metaReg = RegExp(
      r"<(meta|link)(.*?)\/?>|<title(.*?)</title>",
      caseSensitive: false,
      dotAll: true);
  static final RegExp _titleReg =
      RegExp("(title|icon|description|image)", caseSensitive: false);
  static final RegExp _lineReg = RegExp(r"[\n\r]|&nbsp;|&gt;");
  static final RegExp _spaceReg = RegExp(r"\s+");

  /// Is it an empty string
  static bool isNotEmpty(String? str) {
    return str != null && str.isNotEmpty;
  }

  /// Get web information
  /// return [InfoBase]
  static InfoBase? getInfoFromCache(String url) {
    final InfoBase? info = _map[url];
    if (info != null) {
      if (!info._timeout.isAfter(DateTime.now())) {
        _map.remove(url);
      }
    }
    return info;
  }

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase?> getInfo(String url,
      {Duration cache = const Duration(hours: 24),
      bool multimedia = true,
      bool useMultithread = false}) async {
    // final start = DateTime.now();

    InfoBase? info = getInfoFromCache(url);
    if (info != null) return info;
    try {
      if (useMultithread)
        info = await _getInfoByIsolate(url, multimedia);
      else
        info = await _getInfo(url, multimedia);

      if (cache != null && info != null) {
        info._timeout = DateTime.now().add(cache);
        _map[url] = info;
      }
    } catch (e) {
      print("Get web error:$url, Error:$e");
    }

    // print("$url cost ${DateTime.now().difference(start).inMilliseconds}");

    return info;
  }

  static Future<InfoBase?> _getInfo(String url, bool multimedia) async {
    final response = await _requestUrl(url);

    if (response == null) return null;
    // print("$url ${response.statusCode}");
    if (multimedia) {
      final String? contentType = response.headers["content-type"];
      if (contentType != null) {
        if (contentType.contains("image/")) {
          return WebImageInfo(image: url);
        } else if (contentType.contains("video/")) {
          return WebVideoInfo(image: url);
        }
      }
    }

    return _getWebInfo(response, url, multimedia);
  }

  static Future<InfoBase?> _getInfoByIsolate(
      String url, bool multimedia) async {
    final sender = ReceivePort();
    final Isolate isolate = await Isolate.spawn(_isolate, sender.sendPort);
    final sendPort = await sender.first as SendPort;
    final answer = ReceivePort();

    sendPort.send([answer.sendPort, url, multimedia]);
    final List<String?>? res = await answer.first;

    InfoBase? info;
    if (res != null) {
      if (res[0] == "0") {
        info = WebInfo(
          title: res[1],
          description: res[2],
          icon: res[3],
          image: res[4],
        );
      } else if (res[0] == "1") {
        info = WebVideoInfo(image: res[1]);
      } else if (res[0] == "2") {
        info = WebImageInfo(image: res[1]);
      }
    }

    sender.close();
    answer.close();
    isolate.kill(priority: Isolate.immediate);

    return info;
  }

  static void _isolate(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    port.listen((message) async {
      final SendPort sender = message[0];
      final String url = message[1];
      final bool multimedia = message[2];

      final info = await _getInfo(url, multimedia);

      if (info is WebInfo) {
        sender.send(["0", info.title, info.description, info.icon, info.image]);
      } else if (info is WebVideoInfo) {
        sender.send(["1", info.image]);
      } else if (info is WebImageInfo) {
        sender.send(["2", info.image]);
      } else {
        sender.send(null);
      }
      port.close();
    });
  }

  static final Map<String, String> _cookies = {
    "weibo.com":
        "YF-Page-G0=02467fca7cf40a590c28b8459d93fb95|1596707497|1596707497; SUB=_2AkMod12Af8NxqwJRmf8WxGjna49_ygnEieKeK6xbJRMxHRl-yT9kqlcftRB6A_dzb7xq29tqJiOUtDsy806R_ZoEGgwS; SUBP=0033WrSXqPxfM72-Ws9jqgMF55529P9D9W59fYdi4BXCzHNAH7GabuIJ"
  };

  static bool _certificateCheck(X509Certificate cert, String host, int port) =>
      true;

  static Future<Response?> _requestUrl(
    String url, {
    int count = 0,
    String? cookie,
    useDesktopAgent = true,
  }) async {
    if (url.contains("m.toutiaoimg.cn")) useDesktopAgent = false;
    Response? res;
    final uri = Uri.parse(url);
    final ioClient = HttpClient()..badCertificateCallback = _certificateCheck;
    final client = IOClient(ioClient);
    /*
    Twitter website doesn't have open graph tags?
    https://stackoverflow.com/a/64332370/5588637
    */
    final request = Request('GET', uri)
      ..followRedirects = false
      ..headers["User-Agent"] = useDesktopAgent ? "WhatsApp/2" : "WhatsApp/2"
      ..headers["cache-control"] = "no-cache"
      ..headers["Cookie"] = cookie ?? _cookies[uri.host] ?? ""
      ..headers["accept"] = "*/*";

    // print(request.headers);
    final stream = await client.send(request);

    if (stream.statusCode == HttpStatus.movedTemporarily ||
        stream.statusCode == HttpStatus.movedPermanently ||
        stream.statusCode == HttpStatus.seeOther) {
      if (stream.isRedirect && count < 6) {
        final String? location = stream.headers['location'];
        if (location != null) {
          url = location;
          if (location.startsWith("/")) {
            url = uri.origin + location;
          }
        }
        if (stream.headers['set-cookie'] != null) {
          cookie = stream.headers['set-cookie'];
        }
        count++;
        client.close();
        // print("Redirect ====> $url");
        return _requestUrl(url, count: count, cookie: cookie);
      }
    } else if (stream.statusCode == HttpStatus.ok) {
      res = await Response.fromStream(stream);
      if (uri.host == "m.tb.cn") {
        final match = RegExp(r"var url = \'(.*)\'").firstMatch(res.body);
        if (match != null) {
          final newUrl = match.group(1);
          if (newUrl != null) {
            return _requestUrl(newUrl, count: count, cookie: cookie);
          }
        }
      }
    }
    client.close();
    if (res == null) print("Get web info empty($url)");
    return res;
  }

  static Future<InfoBase?> _getWebInfo(
      Response response, String url, bool multimedia) async {
    if (response.statusCode == HttpStatus.ok) {
      String? html;
      try {
        html = const Utf8Decoder().convert(response.bodyBytes);
      } catch (e) {
        try {
          html = gbk.decode(response.bodyBytes);
        } catch (e) {
          print("Web page resolution failure from:$url Error:$e");
        }
      }

      if (html == null) {
        print("Web page resolution failure from:$url");
        return null;
      }

      // Improved performance
      // final start = DateTime.now();
      final headHtml = _getHeadHtml(html);
      final document = parser.parse(headHtml);
      // print("dom cost ${DateTime.now().difference(start).inMilliseconds}");
      final uri = Uri.parse(url);

      // get image or video
      if (multimedia) {
        final gif = _analyzeGif(document, uri);
        if (gif != null) return gif;

        final video = _analyzeVideo(document, uri);
        if (video != null) return video;
      }

      String title = _analyzeTitle(document);
      String? description =
          _analyzeDescription(document, html)?.replaceAll(r"\x0a", " ");
      if (!isNotEmpty(title)) {
        title = description ?? "";
        description = null;
      }

      final info = WebInfo(
        title: title,
        icon: _analyzeIcon(document, uri),
        description: description ?? "",
        image: _analyzeImage(document, uri),
        redirectUrl: response.request?.url.toString(),
      );
      return info;
    }
    return null;
  }

  static String _getHeadHtml(String html) {
    html = html.replaceFirst(_bodyReg, "<body></body>");
    final matchs = _metaReg.allMatches(html);
    final StringBuffer head = StringBuffer("<html><head>");
    matchs.forEach((element) {
      final String? str = element.group(0);
      if (str != null) {
        if (str.contains(_titleReg)) head.writeln(str);
      }
    });
    head.writeln("</head></html>");
    return head.toString();
  }

  static InfoBase? _analyzeGif(html_dom.Document document, Uri uri) {
    if (_getMetaContent(document, "property", "og:image:type") == "image/gif") {
      final gif = _getMetaContent(document, "property", "og:image");
      if (gif != null) return WebImageInfo(image: _handleUrl(uri, gif));
    }
    return null;
  }

  static InfoBase? _analyzeVideo(html_dom.Document document, Uri uri) {
    final video = _getMetaContent(document, "property", "og:video");
    if (video != null) return WebVideoInfo(image: _handleUrl(uri, video));
    return null;
  }

  static String? _getMetaContent(
      html_dom.Document document, String property, String propertyValue) {
    final meta = document.head?.getElementsByTagName("meta");
    final html_dom.Element? ele =
        meta?.firstWhereOrNull((e) => e.attributes[property] == propertyValue);
    if (ele != null) return ele.attributes["content"]?.trim();
    return null;
  }

  static String _analyzeTitle(html_dom.Document document) {
    final title = _getMetaContent(document, "property", "og:title");
    if (title != null) return title;
    final list = document.head?.getElementsByTagName("title");
    if (list != null && list.isNotEmpty) {
      final tagTitle = list.isNotEmpty ? list.first.text : null;
      if (tagTitle != null) return tagTitle.trim();
    }
    return "";
  }

  static String? _analyzeDescription(html_dom.Document document, String html) {
    final desc = _getMetaContent(document, "property", "og:description");
    if (desc != null) return desc;

    final description = _getMetaContent(document, "name", "description") ??
        _getMetaContent(document, "name", "Description");

    if (!isNotEmpty(description)) {
      // final DateTime start = DateTime.now();
      String body = html.replaceAll(_htmlReg, "");
      body = body.trim().replaceAll(_lineReg, " ").replaceAll(_spaceReg, " ");
      if (body.length > 300) {
        body = body.substring(0, 300);
      }
      // print("html cost ${DateTime.now().difference(start).inMilliseconds}");
      return body;
    }
    return description;
  }

  static String _analyzeIcon(html_dom.Document document, Uri uri) {
    final meta = document.head?.getElementsByTagName("link");
    String? icon = "";
    html_dom.Element? metaIcon;
    // get icon first
    if (meta != null) {
      metaIcon = meta.firstWhereOrNull((e) {
        final rel = (e.attributes["rel"] ?? "").toLowerCase();
        if (rel == "icon") {
          icon = e.attributes["href"];
          if (icon != null && !icon!.toLowerCase().contains(".svg")) {
            return true;
          }
        }
        return false;
      });

      metaIcon ??= meta.firstWhereOrNull((e) {
        final rel = (e.attributes["rel"] ?? "").toLowerCase();
        if (rel == "shortcut icon") {
          icon = e.attributes["href"];
          if (icon != null && !icon!.toLowerCase().contains(".svg")) {
            return true;
          }
        }
        return false;
      });
    }

    if (metaIcon != null) {
      icon = metaIcon.attributes["href"];
    } else {
      return "${uri.origin}/favicon.ico";
    }

    return _handleUrl(uri, icon ?? "");
  }

  static String _analyzeImage(html_dom.Document document, Uri uri) {
    final image = _getMetaContent(document, "property", "og:image");
    return _handleUrl(uri, image ?? "");
  }

  static String _handleUrl(Uri uri, String source) {
    if (isNotEmpty(source) && !source.startsWith("http")) {
      if (source.startsWith("//")) {
        source = "${uri.scheme}:$source";
      } else {
        if (source.startsWith("/")) {
          source = "${uri.origin}$source";
        } else {
          source = "${uri.origin}/$source";
        }
      }
    }
    return source;
  }
}

// https://github.com/dart-lang/sdk/issues/42947#issuecomment-642308224
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
