import 'package:url_launcher/url_launcher.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';

/// Ouvre le canal dans les applications du téléphone.
///
/// L'application n'héberge aucune messagerie : elle passe la main et s'efface.
class UrlContactLauncher implements ContactLauncher {
  const UrlContactLauncher();

  @override
  Future<bool> open(ContactChannel channel, Broker broker) async {
    final Uri? target = _uriFor(channel, broker);
    if (target == null) {
      return false;
    }
    if (!await canLaunchUrl(target)) {
      return false;
    }
    return launchUrl(target, mode: LaunchMode.externalApplication);
  }

  Uri? _uriFor(ContactChannel channel, Broker broker) {
    return switch (channel) {
      ContactChannel.call => Uri(scheme: 'tel', path: broker.phone),
      ContactChannel.sms => Uri(scheme: 'sms', path: broker.phone),
      ContactChannel.whatsapp =>
        broker.whatsapp == null
            ? null
            // `wa.me` n'accepte que des chiffres.
            : Uri.parse(
                'https://wa.me/${broker.whatsapp!.replaceAll(RegExp(r'\D'), '')}',
              ),
      // Le message vocal s'enregistre dans l'application puis se partage ;
      // il n'a pas d'URI propre.
      ContactChannel.voiceMessage => null,
    };
  }
}
