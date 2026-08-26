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
    // `canLaunchUrl` répond faux sur Android 11+ dès qu'une requête `<queries>`
    // manque, et le composeur téléphonique existe sur tous les appareils
    // visés : on tente l'ouverture et on ne renonce que si elle échoue.
    if (channel != ContactChannel.call && !await _canOpen(target)) {
      return false;
    }
    try {
      return await launchUrl(target, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }

  Future<bool> _canOpen(Uri target) async {
    try {
      return await canLaunchUrl(target);
    } on Object {
      return false;
    }
  }

  Uri? _uriFor(ContactChannel channel, Broker broker) {
    return switch (channel) {
      ContactChannel.call => Uri(scheme: 'tel', path: broker.phone),
      // `sms:` et non `smsto:` : iOS ne connaît que le premier, et Android
      // ouvre les deux.
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
