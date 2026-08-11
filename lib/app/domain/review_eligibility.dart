import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';

/// Pourquoi un avis est refusé. Un code, jamais une phrase.
enum ReviewRefusal {
  /// Aucun contact enregistré avec ce courtier.
  noContact,

  /// Le canal a été ouvert mais l'échange n'a pas été confirmé.
  notReached,

  /// Ce contact a déjà donné lieu à un avis.
  alreadyReviewed,
}

/// Résultat d'une demande d'avis.
sealed class ReviewPermission {
  const ReviewPermission();
}

final class ReviewAllowed extends ReviewPermission {
  const ReviewAllowed(this.contact);

  final ContactLog contact;
}

final class ReviewDenied extends ReviewPermission {
  const ReviewDenied(this.reason);

  final ReviewRefusal reason;
}

/// La règle anti-faux-avis du cahier des charges.
///
/// Noter est impossible sans une mise en relation enregistrée **et** confirmée
/// comme ayant abouti, **et** pas encore consommée. C'est la seule chose qui
/// donne une valeur aux notes affichées : sans elle, le classement se
/// fabrique.
class ReviewEligibilityService {
  const ReviewEligibilityService(this._contacts);

  final ContactRepository _contacts;

  Future<ReviewPermission> forContact(String contactId) async {
    final ContactLog? contact = await _contacts.byId(contactId);
    if (contact == null) {
      return const ReviewDenied(ReviewRefusal.noContact);
    }
    if (contact.reviewId != null) {
      return const ReviewDenied(ReviewRefusal.alreadyReviewed);
    }
    if (contact.outcome != ContactOutcome.reached) {
      return const ReviewDenied(ReviewRefusal.notReached);
    }
    return ReviewAllowed(contact);
  }

  /// Le premier contact éligible avec ce courtier, s'il en existe un.
  Future<ReviewPermission> forBroker(String brokerId) async {
    final List<ContactLog> all = await _contacts.all();
    final List<ContactLog> mine = all
        .where((ContactLog c) => c.brokerId == brokerId)
        .toList();

    if (mine.isEmpty) {
      return const ReviewDenied(ReviewRefusal.noContact);
    }
    for (final ContactLog contact in mine) {
      if (contact.allowsReview) {
        return ReviewAllowed(contact);
      }
    }
    // On distingue « jamais abouti » de « déjà noté » : les deux mènent à des
    // écrans différents.
    final bool anyReached = mine.any(
      (ContactLog c) => c.outcome == ContactOutcome.reached,
    );
    return ReviewDenied(
      anyReached ? ReviewRefusal.alreadyReviewed : ReviewRefusal.notReached,
    );
  }
}
