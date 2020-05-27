part of flutter_link_preview;

abstract class InfoBase {
  DateTime _timeout;
}

/// Web Information
class WebInfo extends InfoBase {
  final String title;
  final String icon;
  final String description;
  DateTime _timeout;

  WebInfo({this.title, this.icon, this.description});
}

class ImageInfo extends InfoBase {
  final String url;
  DateTime _timeout;

  ImageInfo({this.url});
}

/// Web analyzer
class WebAnalyzer {
  static Map<String, InfoBase> _map = {};

  /// Is it an empty string
  static bool isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase> getInfo(String url, Duration cache) async {
    InfoBase info = _map[url];
    if (info != null) {
      if (info._timeout.isAfter(DateTime.now())) {
        return info;
      } else {
        _map.remove(url);
      }
    }
    try {
      final response = await http.get(url);

      final String contentType = response.headers["content-type"];
      if (contentType.indexOf("image/") > -1) {
        return ImageInfo(url: url);
      }

      info = _getWebInfo(response, url);
      if (cache != null && info != null) {
        info._timeout = DateTime.now().add(cache);
        _map[url] = info;
      }
    } catch (e) {
      print("Get web info error($url) $e");
    }

    return info;
  }

  static WebInfo _getWebInfo(http.Response response, String url) {
    if (response.statusCode == 200) {
      String body;
      try {
        body = Utf8Decoder().convert(response.bodyBytes);
      } catch (e) {
        print("Web page resolution failure from : $url");
        return null;
      }

      final document = parser.parse(body);
      final info = WebInfo(
        title: _analyzeTitle(document),
        icon: _analyzeIcon(document, url),
        description: _analyzeDescription(document),
      );
      return info;
    }
    return null;
  }

  static String _getHost(String url) {
    Uri uri = Uri.parse(url);
    return uri.host;
  }

  static String _analyzeTitle(Document document) {
    final list = document.head.getElementsByTagName("title");
    if (list.isNotEmpty) {
      final tagTitle = list.first.text;
      if (tagTitle != null) {
        return tagTitle;
      }
    }

    return "";
  }

  static String _analyzeDescription(Document document) {
    final meta = document.head.getElementsByTagName("meta");
    String description = "";
    final metaDescription = meta.firstWhere(
        (e) => e.attributes["name"] == "description",
        orElse: () => null);

    if (metaDescription != null) {
      description = metaDescription.attributes["content"];
    }
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
        if (icon != null && icon.toLowerCase().indexOf(".svg") == -1) {
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

    if (isNotEmpty(icon)) {
      if (!icon.startsWith("http")) {
        if (icon.startsWith("//")) {
          icon = icon.replaceFirst("//", "http://");
        } else {
          icon = "http://" + _getHost(url) + icon;
        }
      }
    } else {
      print("Icon not available from : $url");
    }
    return icon;
  }
}
