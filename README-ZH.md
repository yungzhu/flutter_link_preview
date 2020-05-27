# flutter_link_preview

这是一个网址预览插件，可以预览网址的内容。

文档语言: [English](README.md) | [中文简体](README-ZH.md)

![Demo](demo.jpg)

![Gif](gif.jpg)

## 特色功能

-   有结果缓存及过期机制，能更快地返回结果
-   有更好的容错能力，多种方式查找 icon
-   更好的支持中文，没有乱码
-   支持 gif 等图片预览

## 开始入门

```
FlutterLinkPreview(
    url: "https://github.com",
    titleStyle: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
    ),
)
```

结果:

![Result Image](web.jpg)

> 你也可以使用 builder 函数进行自定义渲染

> [点击这里查看详细示例](example/lib/mian.dart).
