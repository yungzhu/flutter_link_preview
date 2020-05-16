# flutter_link_preview

This is a URL preview plugin that previews the content of a URL

![Demo](demo.jpg)

## Special feature

-   Caching mechanism to return results faster
-   Better fault tolerance.
-   Support Chinese no mess code

## Getting Started

```
FlutterLinkPreview(
    url: "https://github.com",
    titleStyle: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
    ),
)
```

Result:

![Result Image](web.jpg)

> You can also use builder to display custom styles
