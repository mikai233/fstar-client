import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstar/utils/utils.dart';

typedef OnComplete = void Function(
    InAppWebViewController inAppWebViewController, Uri uri);

class FStarWebView extends StatefulWidget {
  final String url;
  final OnComplete onLoadComplete;

  const FStarWebView({Key key, @required this.url, this.onLoadComplete})
      : assert(url != null),
        super(key: key);

  @override
  State createState() => _FStarWebViewState();
}

class _FStarWebViewState extends State<FStarWebView> {
  double _value = 0;
  InAppWebViewController _appWebViewController;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _appWebViewController.canGoBack()) {
          _appWebViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Container(
            height: 35,
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onSubmitted: (value) {
                _focusNode.unfocus();
                _appWebViewController.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(value)));
              },
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: isDarkMode(context)
                    ? Theme.of(context).backgroundColor
                    : Color.fromRGBO(240, 240, 240, 1),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: TextButton(
                  onPressed: () {
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                    }
                    _appWebViewController.loadUrl(
                        urlRequest: URLRequest(
                            url: Uri.parse(_textController.text.trim())));
                  },
                  child: Text('搜索'),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(3.0),
            child: NeumorphicProgress(
              style: ProgressStyle(
                  variant: Theme.of(context).backgroundColor,
                  accent: Theme.of(context).primaryColor),
              percent: _value,
            ),
          ),
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              onPressed: () {
                _appWebViewController.reload();
              },
              icon: Icon(
                FontAwesomeIcons.redo,
                size: 16,
              ),
            )
          ],
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          onProgressChanged: (controller, updateValue) {
            setState(() {
              _value = updateValue / 100;
            });
          },
          onCloseWindow: (controller) {
            CookieManager.instance().deleteAllCookies();
          },
          onWebViewCreated: (controller) {
            _appWebViewController = controller;
          },
          onLoadStart: (controller, url) {
            _textController.text = url.toString();
          },
          onLoadStop: (controller, url) {
            _appWebViewController.evaluateJavascript(source: r'''
            window.showModalDialog=window.open;
            ''');
            //onLoadComplete为null也没关系
            widget.onLoadComplete(controller, url);
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
        ),
      ),
    );
  }
}
