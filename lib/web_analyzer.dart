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
  static final RegExp _bodyReg = RegExp(r"<body[^>]*>([\s\S]*)<\/body>");
  static final RegExp _scriptReg = RegExp(r"<script[^>]*>([\s\S]*?)<\/script>");

  /// Is it an empty string
  static bool isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase> getInfo(String url,
      {Duration cache, bool multimedia = true}) async {
    // url = url.replaceFirst("https", "http");
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

  static Future<http.Response> _requestUrl(String url, {int count = 0}) async {
    http.Response response;
    try {
      final uri = Uri.parse(url);
      response = await http.get(url, headers: {
        "User-Agent":
            "com.apple.WebKit.Networking/8609.2.9.0.5 CFNetwork/1126 Darwin/19.5.0",
        "Host": uri.host,
      });
    } catch (e) {
      if (count < 5) {
        if (e.message != null && e.message == "Redirect limit exceeded" ||
            e.message == "Redirect loop detected") {
          count++;
          print("Redirect:${e.uri} Error:$e");
          return _requestUrl(e.uri.toString());
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
      String body;
      try {
        body = const Utf8Decoder().convert(response.bodyBytes);
      } catch (e) {
        try {
          body = await CharsetConverter.decode("gbk", response.bodyBytes);
        } catch (e) {
          print("Web page resolution failure from:$url Error:$e");
          return null;
        }
      }

      // Improved performance
      body = body.replaceFirst(_bodyReg, "<body></body>");
      body = body.replaceAll(_scriptReg, "");
      final document = parser.parse(body);

      // get image or video
      if (multimedia) {
        final gif = _analyzeGif(document, url);
        if (gif != null) return gif;

        final video = _analyzeVideo(document, url);
        if (video != null) return video;
      }

      final info = WebInfo(
        title: _analyzeTitle(document),
        icon: _analyzeIcon(document, url),
        description: _analyzeDescription(document),
      );
      return info;
    }
    return null;
  }

  static InfoBase _analyzeGif(Document document, String url) {
    if (_getMetaContent(document, "property", "og:image:type") == "image/gif") {
      final gif = _getMetaContent(document, "property", "og:image");
      if (gif != null) return ImageInfo(url: _handleUrl(url, gif));
    }
    return null;
  }

  static InfoBase _analyzeVideo(Document document, String url) {
    final video = _getMetaContent(document, "property", "og:video");
    if (video != null) return VideoInfo(url: _handleUrl(url, video));
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

  static String _getHost(String url) {
    final Uri uri = Uri.parse(url);
    return uri.host;
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

  static String _analyzeDescription(Document document) {
    final desc = _getMetaContent(document, "property", "og:description");
    if (desc != null) return desc;

    final description = _getMetaContent(document, "name", "description") ??
        _getMetaContent(document, "name", "Description");
    return description;
  }

  static String _analyzeIcon(Document document, String url) {
    final meta = document.head.getElementsByTagName("link");
    String icon = "";
    final metaIcon = meta.firstWhere((e) {
      final rel = e.attributes["rel"];
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
      final meta = document.head.getElementsByTagName("meta");
      final metaDescription = meta.firstWhere(
          (e) => e.attributes["property"] == "og:image",
          orElse: () => null);

      if (metaDescription != null) {
        icon = metaDescription.attributes["content"];
      }
    }

    return _handleUrl(url, icon);
  }

  static String _handleUrl(String host, String source) {
    if (isNotEmpty(source)) {
      if (!source.startsWith("http")) {
        if (source.startsWith("//")) {
          source = source.replaceFirst("//", "http://");
        } else {
          source = "http://${_getHost(host)}$source";
        }
      }
    }
    return source;
  }
}
