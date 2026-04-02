import 'package:url_launcher/url_launcher.dart';

class ContactSupport {
  static Future<void> sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@ebus-vectalia.ma',
      query: 'subject=Support&body=Bonjour,',
    );
    if(!await launchUrl(
      emailLaunchUri,
      mode: LaunchMode.externalApplication,
      )) {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  static Future<void> callSupport() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '0623456789',
    );
    if (!await launchUrl(
      phoneLaunchUri,
      mode: LaunchMode.externalApplication,
      )
      ) {
      throw 'Impossible de passer l’appel';
    }
  }
}
