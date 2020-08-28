import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller;
  int _index = -1;
  final List<String> _urls = [
    "https://mp.weixin.qq.com/s/qj7gkU-Pbdcdn3zO6ZQxqg",
    "https://mp.weixin.qq.com/s/43GznPLxi5i3yOdvrlr1JQ",
    "https://m.tb.cn/h.VFcZsnK?sm=34cd13",
    "http://world.people.com.cn/n1/2020/0805/c1002-31811808.html",
    "http://www.xinhuanet.com/politics/2020-08/05/c_1126329745.htm",
    "https://news.cctv.com/2020/08/06/ARTIA9lQegWYYPovyw9E3jnf200806.shtml?spm=C96370.PsikHJQ1ICOX.EZkZSILJCLZn.4",
    "http://news.cri.cn/20200806/1049d3ba-4809-508f-1460-2bdce1f33a86.html",
    "https://caijing.chinadaily.com.cn/a/202008/06/WS5f2b7b6da310a859d09dc56d.html",
    "http://news.china.com.cn/2020-08/06/content_76352540.htm",
    "http://www.ce.cn/cysc/fdc/fc/202008/06/t20200806_35467708.shtml",
    "https://politics.gmw.cn/2020-08/06/content_34064868.htm",
    "http://china.cnr.cn/news/20200806/t20200806_525195132.shtml",
    "http://www.qstheory.cn/laigao/ycjx/2020-08/05/c_1126324384.htm",
    "http://www.cac.gov.cn/2020-08/03/c_1598010260526702.htm",
    "https://news.sina.com.cn/c/2020-08-05/doc-iivhuipn7042863.shtml",
    "https://miaosha.jd.com/#31014227524",
    "https://item.jd.com/100000971722.html",
    "https://weibo.com/1594052081/JexZJlEhw?ref=feedsdk&type=comment#_rnd1596696905622",
    "https://www.sohu.com/a/411693859_120135071?spm=smpc.home.top-news2.3.1596696933374czn63ce&_f=index_news_2",
    "https://new.qq.com/omn/20200805/20200805A03MPB00.html",
    "https://news.163.com/20/0806/10/FJBCHV1I0001899O.html",
    "https://map.baidu.com/poi/%E5%89%8D%E6%B5%B7%E5%B0%8F%E5%AD%A6/@12681414.81788556,2560051.112510002,19z?uid=606ab0d0959d252a0e3dda71&ugc_type=3&ugc_ver=1&device_ratio=2&compat=1&querytype=detailConInfo&da_src=shareurl",
    "http://fund.eastmoney.com/a/202008061583042390.html",
    "https://world.tmall.com/item/592147248181.htm?spm=a21wu.241046-hk.7781739888.3.6b70b6cbZB0umD&pos=2&acm=201704120.1003.2.8397093&id=592147248181&scm=1003.2.201704120.ITEM_592147248181_8397093",
    "https://product.suning.com/0070209732/10511254468.html?safp=d488778a.SFS_10208924.16351894.2&safc=prd.0.0&safpn=10010",
    "https://detail.tmall.com/item.htm?spm=a1z10.1-b-s.w4004-17335910984.4.48f05157FHAlfL&id=566303289846",
    "https://item.taobao.com/item.htm?spm=a21wu.241046-hk.4691948847.23.41cab6cb7gdHEY&scm=1007.15423.84311.100200300000005&id=538615099091&pvid=19713279-e9cd-4a6a-a310-5de483ab88c6",
    "https://haokan.baidu.com/v?vid=6062297959164475327&tab=recommend",
    "https://www.iqiyi.com/v_1efv57e4m38.html?vfrm=pcw_home&vfrmblk=D&vfrmrst=712211_focus_A_image3",
    "https://news.ifeng.com/c/7yi63UqlReS",
    "https://kyfw.12306.cn/otn/leftTicket/init?linktypeid=dc&fs=%E5%8C%97%E4%BA%AC,BJP&ts=%E4%B8%8A%E6%B5%B7,SHH&date=2020-08-06&flag=N,N,Y",
    "https://www.zhihu.com/question/407383265/answer/1387349574",
    "https://www.bilibili.com/video/BV1VC4y187iZ?spm_id_from=333.851.b_7265706f7274466972737431.7",
    "https://live.bilibili.com/22229565?spm_id_from=333.851.b_62696c695f7265706f72745f6c697665.5",
    "https://www.huya.com/clkimmy",
    "https://huodong.cnki.net/yiweizhishi/#/home",
    "https://www.ximalaya.com/youshengshu/12576446/",
    "https://detail.tmall.com/item.htm?id=590368227767&spm=608.13964098.1426976240.2.5b92183auE0ypJ&tg_key=jhs&v=0&umpChannel=juhuasuan&u_channel=juhuasuan",
    "https://detail.vip.com/detail-1710613690-6917957406806078618.html",
    "https://bbs.hupu.com/36997146.html",
    "https://music.163.com/#/playlist?id=4944751157",
  ];
  @override
  void initState() {
    _controller = TextEditingController(
        text:
            "https://www.bilibili.com/video/BV1F64y1c7hd?spm_id_from=333.851.b_7265706f7274466972737431.12");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(controller: _controller),
              Row(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("get"),
                  ),
                  const SizedBox(width: 15),
                  RaisedButton(
                    onPressed: () {
                      _index++;
                      if (_index >= _urls.length) _index = 0;
                      _controller.text = _urls[_index];
                      setState(() {});
                    },
                    child: const Text("next"),
                  ),
                  const SizedBox(width: 15),
                  RaisedButton(
                    onPressed: () {
                      _controller.clear();
                    },
                    child: const Text("clear"),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              FlutterLinkPreview(
                key: ValueKey(_controller.value.text),
                url: _controller.value.text,
                titleStyle: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              const Text("Custom Builder", style: TextStyle(fontSize: 20)),
              const Divider(),
              _buildCustomLinkPreview(context),
            ],
          ),
        ),
      ),
    );
  }

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
}
