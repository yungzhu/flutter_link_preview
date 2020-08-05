part of flutter_link_preview;

abstract class InfoBase {
  DateTime _timeout;
}

/// Web Information
class WebInfo extends InfoBase {
  final String title;
  final String icon;
  final String description;

  WebInfo({this.title, this.icon, this.description});
}

/// Image Information
class ImageInfo extends InfoBase {
  final String url;

  ImageInfo({this.url});
}

/// Video Information
class VideoInfo extends InfoBase {
  final String url;

  VideoInfo({this.url});
}

/// Web analyzer
class WebAnalyzer {
  static final Map<String, InfoBase> _map = {};
  static final RegExp _bodyReg = RegExp(r"<body[^>]*>([\s\S]*?)<\/body>");
  static final RegExp _scriptReg = RegExp(r"<script[^>]*>([\s\S]*?)<\/script>");
  static final RegExp _lineReg = RegExp(r"[\n\r]");
  static final RegExp _spaceReg = RegExp(r"\s+");

  /// Is it an empty string
  static bool isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase> getInfo(String url,
      {Duration cache, bool multimedia = true}) async {
    InfoBase info = _map[url];
    if (info != null) {
      if (info._timeout.isAfter(DateTime.now())) {
        return info;
      } else {
        _map.remove(url);
      }
    }
    try {
      final response = await _requestUrl(url);

      if (response == null) return null;
      print(response.request.headers);
      print(response.statusCode);
      if (multimedia) {
        final String contentType = response.headers["content-type"];
        if (contentType != null) {
          if (contentType.contains("image/")) {
            info = ImageInfo(url: url);
          } else if (contentType.contains("video/")) {
            info = VideoInfo(url: url);
          }
        }
      }

      info ??= await _getWebInfo(response, url, multimedia);

      if (cache != null && info != null) {
        info._timeout = DateTime.now().add(cache);
        _map[url] = info;
      }
    } catch (e) {
      print("Get web info error($url) Error:$e");
    }

    return info;
  }

  static Future<http.Response> _requestUrl(String url,
      {int count = 0, String cookie}) async {
    http.Response response;
    try {
      response = await http.get(url, headers: {
        "User-Agent":
            "com.apple.WebKit.Networking/8609.2.9.0.5 CFNetwork/1126 Darwin/19.5.0",
        // "accept-encoding": "gzip, deflate, br",
        "cache-control": "no-cache",
        // "referer": "https://www.bilibili.com/",
        "Cookie": cookie,
        "accept": "*/*",
      });
      cookie = response.headers["set-cookie"];
    } catch (e) {
      if (count < 5) {
        if (e.message != null && e.message == "Redirect limit exceeded" ||
            e.message == "Redirect loop detected") {
          count++;
          print("Redirect:${e.uri} Error:$e");
          return _requestUrl(e.uri.toString(), count: count, cookie: cookie);
        }
      }
    }
    if (response == null) {
      print("Get web info empty($url)");
    }
    return response;
  }

  static Future<InfoBase> _getWebInfo(
      http.Response response, String url, bool multimedia) async {
    if (response.statusCode == 200) {
      String html;
      try {
        html = const Utf8Decoder().convert(response.bodyBytes);
      } catch (e) {
        try {
          html = await CharsetConverter.decode("gbk", response.bodyBytes);
        } catch (e) {
          print("Web page resolution failure from:$url Error:$e");
        }
      }

      if (html == null) return null;

      // Improved performance
      html = html.replaceAll(_scriptReg, "");
      final nobody = html.replaceFirst(_bodyReg, "<body></body>");
      final document = parser.parse(nobody);
      final uri = Uri.parse(url);

      // get image or video
      if (multimedia) {
        final gif = _analyzeGif(document, uri);
        if (gif != null) return gif;

        final video = _analyzeVideo(document, uri);
        if (video != null) return video;
      }

      final info = WebInfo(
        title: _analyzeTitle(document),
        icon: _analyzeIcon(document, uri),
        description: _analyzeDescription(document, html),
      );
      return info;
    }
    return null;
  }

  static InfoBase _analyzeGif(Document document, Uri uri) {
    if (_getMetaContent(document, "property", "og:image:type") == "image/gif") {
      final gif = _getMetaContent(document, "property", "og:image");
      if (gif != null) return ImageInfo(url: _handleUrl(uri, gif));
    }
    return null;
  }

  static InfoBase _analyzeVideo(Document document, Uri uri) {
    final video = _getMetaContent(document, "property", "og:video");
    if (video != null) return VideoInfo(url: _handleUrl(uri, video));
    return null;
  }

  static String _getMetaContent(
      Document document, String property, String propertyValue) {
    final meta = document.head.getElementsByTagName("meta");
    final ele = meta.firstWhere((e) => e.attributes[property] == propertyValue,
        orElse: () => null);
    if (ele != null) return ele.attributes["content"];
    return null;
  }

  static String _analyzeTitle(Document document) {
    final title = _getMetaContent(document, "property", "og:title");
    if (title != null) return title;
    final list = document.head.getElementsByTagName("title");
    if (list.isNotEmpty) {
      final tagTitle = list.first.text;
      if (tagTitle != null) return tagTitle;
    }
    return "";
  }

  static String _analyzeDescription(Document document, String html) {
    final desc = _getMetaContent(document, "property", "og:description");
    if (desc != null) return desc;

    final description = _getMetaContent(document, "name", "description") ??
        _getMetaContent(document, "name", "Description");

    if (!isNotEmpty(description)) {
      final allDom = parser.parse(html);
      String body = allDom.body.text ?? "";
      body = body.trim().replaceAll(_lineReg, " ").replaceAll(_spaceReg, " ");
      if (body.length > 200) {
        body = body.substring(0, 200);
      }
      return body;
    }
    return description;
  }

  static String _analyzeIcon(Document document, Uri uri) {
    final meta = document.head.getElementsByTagName("link");
    String icon = "";
    final metaIcon = meta.firstWhere((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "icon" ||
          rel == "shortcut icon" ||
          rel == "fluid-icon" ||
          rel == "apple-touch-icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    }, orElse: () => null);

    if (metaIcon != null) {
      icon = metaIcon.attributes["href"];
    } else {
      return "${uri.origin}/favicon.ico";
    }

    return _handleUrl(uri, icon);
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
