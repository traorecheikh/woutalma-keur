import type { LegalSection } from '@/components/legal-page';

export type LegalDoc = { title: string; updated: string; intro: string; sections: LegalSection[] };

const updated = '2 septembre 2026';

const confidentialite: LegalDoc = {
  title: 'Politique de confidentialité',
  updated,
  intro: 'Ce que Woutalma Keur enregistre, pourquoi, qui peut le voir, et comment le supprimer.',
  sections: [
    {
      title: 'Responsable du traitement',
      paragraphs: [
        'Woutalma Keur est éditée par LIC, Dakar, Sénégal. LIC est responsable du traitement des données décrites ici. Pour toute question, utilisez les contacts indiqués en bas de page.',
      ],
    },
    {
      title: 'Données collectées',
      paragraphs: ["Nous collectons uniquement les données nécessaires au fonctionnement de l'application."],
      list: [
        'Compte : numéro de téléphone (identifiant de connexion, confirmé par code SMS) ou compte Google, nom facultatif, rôle (client, courtier ou agence).',
        'Courtier ou agence : nom, photo ou logo, téléphone, WhatsApp, zone de couverture, description, documents de vérification (pièce d’identité ou registre de commerce).',
        'Biens : type, transaction, quartier, prix, surface, pièces, description, photos, message vocal facultatif, statut.',
        'Activité client : journal des contacts (courtier, canal, date, résultat déclaré), avis publiés après un contact.',
        "Position : uniquement si vous l'activez, pour trier les résultats par distance. Elle n'est pas conservée sur nos serveurs.",
        'Données techniques : journaux d’erreurs côté serveur et version de l’application, nécessaires au maintien du service.',
      ],
    },
    {
      title: 'Finalités',
      paragraphs: ['Ces données servent à :'],
      list: [
        'afficher les courtiers, agences et biens proches, et permettre le contact par appel, WhatsApp ou SMS ;',
        'vérifier l’identité des courtiers et agences avant d’afficher le badge « Vérifié » ;',
        'n’autoriser un avis qu’après un contact réel et classer les profils de façon explicable ;',
        'sécuriser l’accès aux comptes et prévenir les abus ;',
        'assurer le fonctionnement technique et corriger les erreurs.',
      ],
    },
    {
      title: 'Ce qui est visible publiquement',
      paragraphs: [
        'Le profil d’un courtier ou d’une agence (nom, photo, zone, statut de vérification, note, réactivité, biens disponibles, avis reçus) est visible par toute personne utilisant l’application, sans compte.',
        'Le numéro d’un client n’est jamais affiché à un courtier. Le journal des contacts et les avis en attente ne sont visibles que par le client concerné. Les documents de vérification ne sont visibles que par l’équipe de modération.',
      ],
    },
    {
      title: 'Partage des données',
      paragraphs: [
        'Nous ne vendons ni ne louons aucune donnée. Aucune donnée n’est transmise à des annonceurs.',
        'Les données sont hébergées chez Render (serveurs situés dans l’Union européenne, Francfort). Ce prestataire agit uniquement pour notre compte. La connexion par compte Google passe par les services de Google, selon leurs propres conditions.',
        'Lorsque vous appelez un courtier ou lui écrivez sur WhatsApp ou par SMS, l’échange se fait en dehors de Woutalma Keur et relève des conditions de ces services.',
      ],
    },
    {
      title: 'Conservation',
      paragraphs: [
        'Les données d’un compte sont conservées tant que le compte existe. À la suppression du compte depuis le profil, le compte, ses biens, ses fichiers (photos, messages vocaux, documents) sont supprimés définitivement. Les avis publiés sont anonymisés.',
        'La copie locale sur le téléphone se supprime depuis le profil ou en désinstallant l’application. Les journaux techniques sont conservés au plus 30 jours.',
      ],
    },
    {
      title: 'Sécurité',
      paragraphs: [
        'Les échanges entre l’application et nos serveurs sont chiffrés (HTTPS). Les jetons de session sont stockés dans l’espace sécurisé du téléphone. L’accès aux données est limité aux personnes chargées du service et de la modération.',
      ],
    },
    {
      title: 'Vos droits',
      paragraphs: [
        'Vous pouvez à tout moment consulter et corriger vos informations depuis l’application, et supprimer définitivement votre compte depuis le profil.',
        'Conformément à la loi sénégalaise n° 2008-12 sur la protection des données à caractère personnel, vous disposez d’un droit d’accès, de rectification, d’opposition et de suppression. Pour l’exercer, contactez-nous par les moyens indiqués en bas de page.',
      ],
    },
    {
      title: 'Mineurs',
      paragraphs: ["L'application n'est pas destinée aux personnes de moins de 16 ans. Nous ne collectons pas sciemment de données les concernant."],
    },
    {
      title: 'Modifications',
      paragraphs: ['Cette politique peut évoluer. La date de mise à jour figure en haut de page. Les changements importants sont signalés dans l’application.'],
    },
  ],
};

const conditions: LegalDoc = {
  title: "Conditions d'utilisation",
  updated,
  intro: 'Les règles qui s’appliquent aux clients, aux courtiers et aux agences qui utilisent Woutalma Keur.',
  sections: [
    {
      title: 'Objet',
      paragraphs: [
        'Woutalma Keur est une application mobile éditée par LIC. Elle met en relation des particuliers qui cherchent un bien à louer ou à acheter et des courtiers ou agences immobilières au Sénégal, et permet à ces derniers de publier leurs biens.',
        'En installant ou en utilisant l’application, vous acceptez les présentes conditions.',
      ],
    },
    {
      title: 'Accès et compte',
      paragraphs: [
        'La consultation des courtiers, agences et biens est libre, sans compte. Un compte est nécessaire pour contacter un courtier depuis l’application, laisser un avis, ou publier des biens.',
        'Le compte est lié à un numéro de téléphone confirmé par code SMS, ou à un compte Google. Vous êtes responsable des actions effectuées depuis votre compte.',
        'L’application est réservée aux personnes de 16 ans et plus.',
      ],
    },
    {
      title: 'Engagements des utilisateurs',
      paragraphs: ['Vous vous engagez à :'],
      list: [
        'fournir des informations exactes et les tenir à jour ;',
        'respecter les autres utilisateurs, sans propos injurieux, discriminatoires ou trompeurs ;',
        'ne publier que des photos, descriptions et messages vocaux dont vous détenez les droits ;',
        'ne pas utiliser l’application à des fins de démarchage abusif, de fraude ou de collecte de données ;',
        'ne pas tenter de contourner les mesures de sécurité ou de perturber le service.',
      ],
    },
    {
      title: 'Courtiers et agences',
      paragraphs: [
        'Un courtier ou une agence est responsable de l’exactitude de son profil et de ses biens : prix, statut, quartier, photos. Un bien vendu ou loué doit être marqué comme tel ; il disparaît alors de la recherche.',
        'Le badge « Vérifié » signale un profil dont l’identité ou le registre de commerce a été confirmé par LIC. Il ne garantit ni la qualité des prestations ni la disponibilité des biens.',
      ],
    },
    {
      title: 'Avis',
      paragraphs: [
        'Un avis ne peut être laissé qu’après un contact enregistré avec le courtier concerné, et une seule fois par contact. Les avis doivent refléter une expérience réelle. LIC peut retirer un avis manifestement faux, injurieux ou hors sujet, et le courtier peut y répondre publiquement.',
      ],
    },
    {
      title: 'Relation client-courtier',
      paragraphs: [
        'Visites, négociations, contrats et paiements relèvent de l’accord direct entre le client et le courtier ou l’agence. Woutalma Keur n’est pas partie à cette relation, ne perçoit aucune commission, ne traite aucun paiement et n’intervient pas dans les litiges.',
      ],
    },
    {
      title: 'Gratuité',
      paragraphs: ['L’application est gratuite pour les clients, les courtiers et les agences. LIC se réserve le droit de proposer à l’avenir des services optionnels payants, qui feront l’objet de conditions spécifiques.'],
    },
    {
      title: 'Installation et mises à jour',
      paragraphs: [
        'L’application est distribuée par Google Play et l’App Store. N’installez pas de fichier obtenu ailleurs. Une version minimale peut être imposée : l’application vous invite alors à la mettre à jour.',
      ],
    },
    {
      title: 'Propriété intellectuelle',
      paragraphs: [
        'L’application, son nom, son logo et son contenu éditorial appartiennent à LIC. Les contenus publiés par les utilisateurs (photos, descriptions, messages vocaux, avis) restent leur propriété ; ils accordent à LIC le droit de les afficher dans l’application.',
      ],
    },
    {
      title: 'Suspension et suppression',
      paragraphs: [
        'LIC peut suspendre ou supprimer un compte ou un bien en cas de manquement aux présentes conditions, après notification sauf urgence. Vous pouvez supprimer votre compte à tout moment depuis le profil.',
      ],
    },
    {
      title: 'Responsabilité',
      paragraphs: [
        'L’application est fournie en l’état. LIC met en œuvre des moyens raisonnables pour assurer sa disponibilité mais ne garantit pas un fonctionnement ininterrompu. LIC n’est pas responsable des prestations des courtiers et agences ni des échanges réalisés en dehors de l’application.',
      ],
    },
    {
      title: 'Droit applicable',
      paragraphs: ['Les présentes conditions sont soumises au droit sénégalais. Tout litige relève des tribunaux compétents de Dakar, après recherche d’une solution amiable.'],
    },
  ],
};

const aPropos: LegalDoc = {
  title: 'À propos',
  updated,
  intro: 'Pourquoi Woutalma Keur existe, qui la fait, et ce qu’elle refuse de faire.',
  sections: [
    {
      title: 'Le problème',
      paragraphs: [
        'Chercher un logement à Dakar, c’est enchaîner les appels à des numéros trouvés au hasard, sans savoir qui répond, si le bien existe encore, ni si la personne est fiable. Pour quelqu’un qui lit difficilement ou qui a un petit téléphone sur un réseau lent, c’est encore plus long.',
      ],
    },
    {
      title: 'Ce que fait l’application',
      paragraphs: [
        'Elle montre les courtiers et agences proches, vérifiés, avec leurs biens disponibles, et permet de les appeler en trois écrans. Chaque fiche se lit à voix haute. Les avis ne viennent que de personnes qui ont réellement pris contact.',
        'Côté courtier, elle offre un profil public, la publication de biens avec photos et message vocal, la vérification d’identité et un classement local expliqué.',
      ],
    },
    {
      title: 'Ce qu’elle ne fait pas',
      paragraphs: [
        'Pas de paiement, pas de contrat, pas de messagerie interne, pas de publicité. Le contact passe par le téléphone, WhatsApp ou SMS, et la relation reste entre le client et le courtier.',
      ],
    },
    {
      title: 'Qui',
      paragraphs: [
        'Woutalma Keur est conçue et éditée par LIC, à Dakar. L’application est construite avec Flutter, le serveur avec NestJS et PostgreSQL, hébergé chez Render à Francfort.',
      ],
    },
  ],
};

export const legal = { confidentialite, conditions, 'a-propos': aPropos } as const;
