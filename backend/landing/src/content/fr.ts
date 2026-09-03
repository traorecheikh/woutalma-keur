export const nav = {
  links: [
    { href: '/#clients', label: 'Clients' },
    { href: '/#courtiers', label: 'Courtiers' },
    { href: '/#installer', label: 'Installer' },
  ],
  download: 'Télécharger',
};

export const hero = {
  title: 'Un courtier vérifié. Près de chez vous. Un appel.',
  lead: 'Trouvez un contact pertinent et appelez-le en trois écrans maximum. Location, achat ou terrain, à Dakar.',
  caption: (version: string) => `Gratuit · version ${version} · aucun compte requis pour explorer.`,
  secondary: 'Voir comment ça marche',
  screen: { src: '/screens/c01-explorer.webp', alt: "Accueil de l'application : quartier actuel, recherche et courtiers de confiance à proximité" },
  photo: { src: '/photos/apartment-ngor-coast.webp', alt: '' },
};

export const clientStory = {
  eyebrow: 'Pour les clients',
  title: 'Trois écrans, puis un appel.',
  steps: [
    {
      title: 'Cherchez près de chez vous.',
      body: 'Votre quartier, un rayon, un type de bien. Les résultats se mettent à jour pendant la frappe.',
      screen: '/screens/c01-explorer.webp',
      alt: "Écran d'accueil avec la rangée « Près de chez vous »",
    },
    {
      title: 'Regardez la fiche.',
      body: 'Identité vérifiée, distance, note, réactivité, biens disponibles et avis de clients qui ont vraiment appelé.',
      screen: '/screens/c02-courtier.webp',
      alt: "Fiche d'un courtier vérifié avec note, distance et biens disponibles",
    },
    {
      title: 'Appelez.',
      body: 'Appel, WhatsApp ou SMS, avec les applications de votre téléphone. Sans intermédiaire, sans paiement.',
      screen: '/screens/m04-contacter.webp',
      alt: 'Feuille Contacter : Appeler, WhatsApp, SMS',
    },
  ],
};

export const trust = {
  eyebrow: 'Confiance',
  title: 'Quatre règles, pas de promesses.',
  rules: [
    "L'identité et le registre de chaque courtier sont vérifiés avant le badge.",
    "Un avis n'est possible qu'après un contact réel. Un seul avis par contact.",
    "Votre numéro n'est jamais affiché. C'est vous qui appelez.",
    'Un bien vendu ou loué disparaît immédiatement de la recherche.',
  ],
};

export const access = {
  eyebrow: 'Accessibilité',
  title: 'Lue à voix haute. Gros boutons. Pensée pour la 3G.',
  body: "Chaque résultat se lit à voix haute d'un geste. Les actions font 56 points de haut, les pictogrammes accompagnent toujours un mot, et l'application garde une copie locale pour les réseaux lents.",
  spoken: '3 résultats. Maison à Plateau, 1 000 000 francs par mois. Appartement à Point E, 150 000 francs par mois. Appartement à Mermoz, 20 000 000 francs.',
  screen: { src: '/screens/c04-resultats.webp', alt: 'Résultats de recherche avec le bouton Écouter' },
  photo: { src: '/photos/house-medina-street.webp', alt: '' },
};

export const brokerStory = {
  eyebrow: 'Pour les courtiers et agences',
  title: 'Publiez. Faites-vous vérifier. Soyez classé.',
  lead: "Un profil public, des biens avec photos et message vocal, un classement local qui récompense la réactivité.",
  steps: [
    {
      title: 'Publiez un bien en trois étapes.',
      body: 'Type, quartier et prix, puis photos et message vocal de 45 secondes. Titre composé automatiquement.',
      screen: '/screens/b03-ajouter.webp',
      alt: "Première étape de l'ajout d'un bien : type, transaction et quartier",
    },
    {
      title: 'Faites vérifier votre identité.',
      body: "Pièce d'identité ou registre de commerce, photo du document, réponse dans l'application.",
      screen: '/screens/b09-verification.webp',
      alt: "Écran de vérification d'identité avec les étapes et le statut",
    },
    {
      title: 'Soyez classé par votre réactivité.',
      body: 'Note, volume d’avis, proximité et taux de réponse. Le classement est expliqué, pas deviné.',
      screen: '/screens/b10-classement.webp',
      alt: 'Classement local avec la décomposition note, avis, proximité, réponse',
    },
  ],
  slider: [
    { src: '/screens/c03-bien.webp', alt: "Fiche d'un bien avec photos, prix et courtier" },
    { src: '/screens/b01-accueil.webp', alt: 'Accueil courtier : vérification, contacts, biens' },
    { src: '/screens/c04-resultats.webp', alt: 'Résultats de recherche lus à voix haute' },
    { src: '/screens/m04-contacter.webp', alt: 'Choix du canal : appel, WhatsApp ou SMS' },
  ],
};

export const install = {
  title: 'Installez Woutalma Keur.',
  lead: (version: string) => `Version ${version}, gratuite, Android en priorité.`,
  steps: [
    { title: 'Scannez le code ou touchez un badge.', body: 'Le code QR ouvre cette page sur votre téléphone.' },
    { title: 'Installez depuis votre store.', body: 'Google Play sur Android, App Store sur iPhone. Aucun fichier à télécharger ailleurs.' },
    { title: 'Explorez sans compte.', body: 'Votre numéro est demandé seulement au moment de contacter ou de noter un courtier.' },
  ],
  soon: "Bientôt disponible sur Google Play et l'App Store.",
  photo: { src: '/photos/land-parcelles-road.webp', alt: '' },
};

export const footer = {
  contact: 'Contact',
  legal: 'Légal',
  credits: 'Photos',
  privacy: 'Confidentialité',
  terms: "Conditions d'utilisation",
  about: 'À propos',
  whatsapp: 'WhatsApp',
  email: 'Email',
  credit: 'Un produit LIC',
  version: (version: string) => `Version ${version}`,
};
