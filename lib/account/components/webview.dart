import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/custom_widgets.dart';

class GuideWebview extends StatefulWidget {
  const GuideWebview({Key? key}) : super(key: key);

  @override
  State<GuideWebview> createState() => _GuideWebviewState();
}

class _GuideWebviewState extends State<GuideWebview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Help Center",
      ),

      // ...

      //   body: WebView(
      //   initialUrl: 'https://drive.google.com/file/d/1oYQXDplp_ejKEa2Zv8bWd2k-fqEPv-x5/view?usp=sharing',
      //   javascriptMode: JavascriptMode.unrestricted,
      // ),
    );
  }
}
