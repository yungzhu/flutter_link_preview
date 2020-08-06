# flutter_link_preview

This is a URL preview plugin that previews the content of a URL

Language: [English](README.md) | [中文简体](README-ZH.md)

![Demo](images/demo.jpg)

![Gif](images/gif.jpg)

## Special feature

-   Support for content caching and expiration mechanisms to return results faster.
-   Better fault tolerance, multiple ways to find icons, titles, descriptions
-   Better support gbk code, no messy code
-   Optimized for large files with better crawl performance.
-   Support for second hop authentication with cookies
-   Support gif, video and other content capture

## Getting Started

```dart
FlutterLinkPreview(
    url: "https://github.com",
    titleStyle: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
    ),
)
```

Result:

![Result Image](images/web.jpg)

> You can also use builder to display custom styles

> [Click here for a detailed example](example/lib/main.dart).
