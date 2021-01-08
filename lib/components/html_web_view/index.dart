import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_plus/components/html_web_view/utils/create_html_document.dart';
import 'package:moegirl_plus/utils/encode_js_eval_codes.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _webViewInjectedSendMessageMethodName = '__webViewMessageChannel';
const basicInjectedJs = '''
  window._postMessage = (type, data) => {
    __webViewMessageChannel.postMessage(JSON.stringify({ type, data }))
  }
''';

class HtmlWebView extends StatefulWidget {
  final String body;
  final String title;
  final List<String> injectedStyles;
  final List<String> injectedScripts;
  final void Function(HtmlWebViewController) onWebViewCreated;
  final Map<String, void Function(dynamic data)> messageHandlers;  

  HtmlWebView({
    Key key,
    this.body,
    this.title,
    this.injectedStyles,
    this.injectedScripts,
    this.onWebViewCreated,
    this.messageHandlers
  }) : super(key: key);

  @override
  _HtmlWebViewState createState() => _HtmlWebViewState();
}

class _HtmlWebViewState extends State<HtmlWebView> {
  String initHtmlDocumentUri;
  WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid && canUsePlatformViewsForAndroidWebview) WebView.platform = SurfaceAndroidWebView();
    WebView.platform = SurfaceAndroidWebView();

    initHtmlDocumentUri = createbaseHtmlDocumentUri();
  }

  @override
  void didUpdateWidget(HtmlWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ([
      widget.body != oldWidget.body,
      widget.injectedScripts.toString() != oldWidget.injectedScripts.toString(),
      widget.injectedStyles.toString() != oldWidget.injectedStyles.toString()
    ].contains(true)) {
      reloadWebView();
    }
  }

  String createbaseHtmlDocumentUri() {        
    return Uri.dataFromString('',
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf8')
    ).toString();
  }

  // 使用document.write代替reload
  Future<void> reloadWebView() async {
    var htmlDocument = createHtmlDocument(widget.body ?? '',
      title: widget.title,
      injectedStyles: widget.injectedStyles,
      injectedScripts: [
        basicInjectedJs, 
        ...?widget.injectedScripts,
        '_postMessage("loaded")'
      ],
    );

    // 转unicode字符串，防止误解析
    final encodedhtmlDocument = await encodeJsEvalCodes(htmlDocument);
    webViewController.evaluateJavascript('''
      document.open('text/html', 'replace')
      document.write('$encodedhtmlDocument')
      document.close()
    ''');
  }

  void javascriptChannelHandler(JavascriptMessage msg) {
    final message = WebViewMessage(msg);
    widget.messageHandlers[message.type](message.data);
  }

  void webViewWasCreatedHandler(WebViewController controller) {
    webViewController = controller;
    reloadWebView();
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated(HtmlWebViewController(
        reload: reloadWebView,
        webViewController: controller
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: initHtmlDocumentUri,
      debuggingEnabled: true,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: webViewWasCreatedHandler,
      javascriptChannels: {
        JavascriptChannel(
          name: _webViewInjectedSendMessageMethodName, 
          onMessageReceived: javascriptChannelHandler
        )
      },
    );
  }
}

class WebViewMessage {
  String type;
  dynamic data;

  WebViewMessage(JavascriptMessage rawMessage) {
    var message = jsonDecode(rawMessage.message);
    type = message['type'];
    data = message['data'];
  }
}

class HtmlWebViewController {
  final void Function() reload; // 自定义一个reload方法
  final WebViewController webViewController;

  HtmlWebViewController({
    this.reload,
    this.webViewController
  });
}