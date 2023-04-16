import 'package:flutter/material.dart';
import 'package:tooday/screens/provacy_policy_screen.dart';
import 'package:tooday/utils/app_localization.dart';

class AboutPage extends StatelessWidget {
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
            AppLocalizations.of(context).translate('About'),
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context).translate(
                        'This app was created by Dimitrios Dimitropoulos.'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context)
                        .translate('Version app : 1.0 (2023)'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context).translate(
                        'I hereby give credits to the Developers that made possible for the app to wokr by there flutter packages:'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'sqflite ${AppLocalizations.of(context).translate('by')}: tekartik.com',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'path_provider  ${AppLocalizations.of(context).translate('by')}: flutter.dev',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'flutter_localization  ${AppLocalizations.of(context).translate('by')}: mastertipsy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'intl ${AppLocalizations.of(context).translate('by')}: dart.dev',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'provider  ${AppLocalizations.of(context).translate('by')}: dash-overflow.net(Remi Rousselet)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'iconly  ${AppLocalizations.of(context).translate('by')}: 6thsolution.com',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'shared_preferences ${AppLocalizations.of(context).translate('by')}: flutter.dev',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context).translate('Privacy Policy'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.0),
                  InkWell(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('Click here to view our privacy policy'),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          decoration: TextDecoration.underline),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
