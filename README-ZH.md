# flutter_link_preview

这是一个网址预览插件，可以预览网址的内容。

文档语言: [English](README.md) | [中文简体](README-ZH.md)

![Demo](images/demo.jpg)

![Gif](images/gif.jpg)

## 特色功能

-   支持内容缓存及过期机制，能更快地返回结果
-   更好的容错能力，多种方式查找 icon,title,descriptions
-   更好的支持中文编码，没有乱码
-   对大文件进行优化，有更好的抓取性能
-   支持携带 cookies 进行二次跳转验证
-   支持 gif，视频 等内容抓取

## 开始入门

```dart
FlutterLinkPreview(
    url: "https://github.com",
    titleStyle: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
    ),
)
```

结果:

![Result Image](images/web.jpg)

> 你也可以使用 builder 函数进行自定义渲染

> [点击这里查看详细示例](example/lib/main.dart).
