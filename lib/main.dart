import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  late PullToRefreshController pullToRefreshController;
  String url = "";
  final urlController = TextEditingController();

  List bookMarksList = [];
  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Web_Browser"),
        actions: [
          IconButton(
            onPressed: () {
              webViewController?.goBack();
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
          ),
          IconButton(
            onPressed: () {
              webViewController?.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse("https://www.google.co.in"),
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              webViewController?.reload();
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goForward();
            },
            icon: const Icon(Icons.arrow_forward_ios_sharp),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                  ),
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  onSubmitted: (value) {
                    var url = Uri.parse(value);
                    if (url.scheme.isEmpty) {
                      url = Uri.parse("https://www.google.com/search?q=$value");
                    }
                    webViewController?.loadUrl(
                        urlRequest: URLRequest(url: url));
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest: URLRequest(
                          url: Uri.parse("https://www.google.co.in"),
                        ),
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStop: (controller, url) async {
                          pullToRefreshController.endRefreshing();
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = url;
                          });
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      bookMarksList.add(url);
                      bookMarksList = bookMarksList.toSet().toList();
                    },
                    mini: true,
                    child: const Icon(Icons.bookmark_add_outlined),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Center(child: Text('All BookMarks')),
                            content: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.75,
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: ListView.separated(
                                itemCount: bookMarksList.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      webViewController?.loadUrl(
                                        urlRequest: URLRequest(
                                          url: Uri.parse(bookMarksList[i]),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      bookMarksList[i],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.blueAccent),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, i) {
                                  return const Divider(
                                    color: Colors.black,
                                    endIndent: 30,
                                    indent: 30,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    mini: true,
                    child: const Icon(Icons.bookmark_border),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
