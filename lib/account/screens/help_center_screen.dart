import 'package:crime/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/custom_widgets.dart';
import '../components/send_email.dart';
import '../components/webview.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  double height = 0;
  double width = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(
        title: "Help Center",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: ListView(
          children: [
            Container(
              color: Colors.grey.shade100,
              margin: EdgeInsets.fromLTRB(25, 40, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "FAQs",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  getFAQItem("How to get the SOS menu bar?",
                      "SOS menu bar can be enabled by turning on switch in Accounts > Enable SOS Menu"),
                  getFAQItem("Why can't I comment on Posts",
                      "In order to get the option to comment on posts, user must be signed into their account!"),
                  getFAQItem("How do I know if my crime report was submitted?",
                      "You will recieve an auto-reply from the Official Police email once your crime report is submitted."),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 40, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                      "Still not sure of how to use the app? Click here to view"
                      "a step-by-step guide with pictures",
                      textAlign: TextAlign.center),
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: getButton("First Time User Guide", () {
                        Navigator.of(context).pushNamed('/guide');
                      })),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("OR",
                        style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                        "Cannot find the solution to your problem in either one of those?"
                        " No worries! Just email us your enquiry",
                        textAlign: TextAlign.center),
                  ),
                  getButton("Send Inquiry", () {
                    getSendInquiryPopUp();
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getFAQItem(String title, String child) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      textColor: Colors.red.shade900,
      iconColor: Colors.red.shade900,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              color: Colors.red.shade50,
              padding: EdgeInsets.all(15),
              child: Text(
                child,
                textAlign: TextAlign.center,
              )),
        )
      ],
    );
  }

  getButton(String text, Function()? onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: ThemeHelper().buttonBoxDecoration(context),
        child: ElevatedButton(
          style: ThemeHelper().buttonStyle(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  getSendInquiryPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendEmail(title: "Inquiry");
        });
  }
}
