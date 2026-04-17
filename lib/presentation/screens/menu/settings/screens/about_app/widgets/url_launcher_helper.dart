import 'package:url_launcher/url_launcher.dart';

Future<void> launchWebUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> launchMailUrl(String email, {String subject = ''}) async {
  final uri = Uri.parse('mailto:$email${subject.isNotEmpty ? '?subject=$subject' : ''}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}