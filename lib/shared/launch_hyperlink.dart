import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlink extends StatelessWidget {
  final String url;
  final String text;

  Hyperlink(this.url, this.text);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launchURL(url);
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
