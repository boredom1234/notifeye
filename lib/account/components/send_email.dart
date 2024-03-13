import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import '../../utils/theme.dart';

class SendEmail extends StatefulWidget {
  String title;

  SendEmail({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  String? message;
  String? email;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send ${widget.title}'),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
          child: Column(
            children: <Widget>[getEmailField(), getMessageField()],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.red.shade900)),
            child: const Text(
              "Send",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final Email email = Email(
                body: _messageController.text, // Get text from message field
                subject: 'FEEDBACK',
                recipients: [
                  'brorizz69@gmail.com'
                ], // Get text from email field
                cc: [],
                isHTML: false,
              );

              await FlutterEmailSender.send(email);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            })
      ],
    );
  }

  Widget getEmailField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: ThemeHelper()
            .textInputDecoration("Email Address", "Enter the email address"),
        onChanged: (val) {
          setState(() {
            email = val;
          });
        },
        validator: (val) {
          if (val!.isEmpty) {
            return "Email Address is required";
          }
          return null;
        },
      ),
    );
  }

  Widget getMessageField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        controller: _messageController,
        minLines: 8,
        maxLines: 12,
        keyboardType: TextInputType.multiline,
        decoration: ThemeHelper()
            .textInputDecoReport("Enter the ${widget.title} message"),
        onChanged: (val) {
          setState(() {
            message = val;
          });
        },
        validator: (val) {
          if (val!.isEmpty) {
            return "Message Content is empty";
          }
          return null;
        },
      ),
    );
  }
}
