import 'package:flutter/material.dart';
import 'package:tooday/utils/app_localization.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, // Change your back button color here
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context).translate('Privacy Policy'),
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Center(
          child: Text(
            '${AppLocalizations.of(context).translate('Privacy Policy')}\n\n'
            '${AppLocalizations.of(context).translate('We take your privacy seriously and do not collect any personal information from you. However, we may collect usage data such as app crashes and usage statistics to improve our app.')}\n\n'
            '${AppLocalizations.of(context).translate('Any data we collect is anonymized and will not be shared with any third-party without your consent.')}\n\n'
            '${AppLocalizations.of(context).translate('If you have any questions or concerns about our privacy policy, please contact us at dimidev1985@gmail.com.')}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
