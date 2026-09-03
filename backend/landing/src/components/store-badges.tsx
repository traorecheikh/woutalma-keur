import { useState } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { install } from '@/content/fr';
import { site } from '@/site.config';
import { cn } from '@/lib/utils';

const stores = [
  { name: 'Google Play', href: site.playStoreUrl, src: '/badges/google-play.png', alt: 'Disponible sur Google Play' },
  { name: 'App Store', href: site.appStoreUrl, src: '/badges/app-store.svg', alt: "Télécharger dans l'App Store" },
];

// Sans URL de fiche, le badge reste un bouton : l'appui révèle le message plutôt qu'un lien mort.
export function StoreBadges({ className }: { className?: string }) {
  const [soon, setSoon] = useState(false);
  return (
    <div className={className}>
      <ul className="flex flex-wrap items-center gap-4">
        {stores.map((s) => (
          <li key={s.name}>
            {s.href ? (
              <a href={s.href} rel="noopener" className="inline-block">
                <img src={s.src} alt={s.alt} className="h-12 w-auto" />
              </a>
            ) : (
              <button type="button" aria-expanded={soon} aria-controls="store-soon" onClick={() => setSoon(true)} className="inline-block">
                <img src={s.src} alt={s.alt} className="h-12 w-auto" />
              </button>
            )}
          </li>
        ))}
      </ul>
      <p id="store-soon" role="status" aria-live="polite" className={cn('text-sm font-medium', soon ? 'mt-3' : 'sr-only')}>
        {soon && install.soon}
      </p>
    </div>
  );
}

export function QrCode({ className }: { className?: string }) {
  return (
    <figure className={cn('inline-flex flex-col items-start gap-3', className)}>
      <div className="border bg-white p-3">
        <QRCodeSVG value={site.url} size={168} level="M" bgColor="#ffffff" fgColor="#0b0b0c" marginSize={0} />
      </div>
      <figcaption className="max-w-[24ch] text-sm text-muted-foreground">Scannez pour ouvrir cette page sur votre téléphone.</figcaption>
    </figure>
  );
}
