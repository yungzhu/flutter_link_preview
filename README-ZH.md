# flutter_link_preview

这是一个网址预览插件，可以预览网址的内容。

文档语言: [English](README.md) | [中文简体](README-ZH.md)

![Demo](images/web1.png)

## 特色功能

-   采用多进程解析网页，避免阻塞主进程
-   支持内容缓存及过期机制，能更快地返回结果
-   更好的容错能力，多种方式查找 icon,title,descriptions,image
-   更好的支持中文编码，没有乱码
-   对大文件进行优化，有更好的抓取性能
-   支持携带 cookies 进行二次跳转验证
-   支持 gif，视频 等内容抓取
-   支持自定义渲染

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

![Result Image](images/web2.png)

## 自定义渲染

```dart
Widget _buildCustomLinkPreview(BuildContext context) {
  return FlutterLinkPreview(
    key: ValueKey("${_controller.value.text}211"),
    url: _controller.value.text,
    builder: (info) {
      if (info == null) return const SizedBox();
      if (info is WebImageInfo) {
        return CachedNetworkImage(
          imageUrl: info.image,
          fit: BoxFit.contain,
        );
      }

      final WebInfo webInfo = info;
      if (!WebAnalyzer.isNotEmpty(webInfo.title)) return const SizedBox();
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF0F1F2),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: webInfo.icon ?? "",
                  imageBuilder: (context, imageProvider) {
                    return Image(
                      image: imageProvider,
                      fit: BoxFit.contain,
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.link);
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    webInfo.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (WebAnalyzer.isNotEmpty(webInfo.description)) ...[
              const SizedBox(height: 8),
              Text(
                webInfo.description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (WebAnalyzer.isNotEmpty(webInfo.image)) ...[
              const SizedBox(height: 8),
              CachedNetworkImage(
                imageUrl: webInfo.image,
                fit: BoxFit.contain,
              ),
            ]
          ],
        ),
      );
    },
  );
}
```

![Result Image](images/web3.png)

## 示例代码

[点击这里查看详细示例](example/lib/main.dart).
