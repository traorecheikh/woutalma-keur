import { useState } from 'react';
import { AppleLogo, GooglePlayLogo } from '@phosphor-icons/react';
import { QRCodeSVG } from 'qrcode.react';
import { Button } from '@/components/ui/button';
import { install, nav } from '@/content/fr';
import { site } from '@/site.config';
import { cn } from '@/lib/utils';

const stores = [
  { name: 'Google Play', href: site.playStoreUrl, Icon: GooglePlayLogo },
  { name: 'App Store', href: site.appStoreUrl, Icon: AppleLogo },
];

// Tant qu'aucune fiche n'est publiée, le bouton révèle « bientôt » au lieu d'ouvrir un lien mort.
export function StoreBadges({ className }: { className?: string }) {
  const [soon, setSoon] = useState(false);
  const download = site.playStoreUrl || site.appStoreUrl;
  return (
    <div className={className}>
      <div className="flex flex-wrap items-center gap-x-6 gap-y-4">
        {download ? (
          <Button asChild size="lg" className="h-12 px-6 text-base font-semibold">
            <a href={download} rel="noopener">
              {nav.download}
            </a>
          </Button>
        ) : (
          <Button
            size="lg"
            className="h-12 px-6 text-base font-semibold"
            aria-expanded={soon}
            aria-controls="store-soon"
            onClick={() => setSoon(true)}
          >
            {nav.download}
          </Button>
        )}
        <ul className="flex items-center gap-5 text-sm font-semibold text-muted-foreground">
          {stores.map(({ name, href, Icon }) => (
            <li key={name} className="flex items-center gap-2">
              <Icon className="size-5 shrink-0" weight="fill" aria-hidden />
              {href ? (
                <a href={href} rel="noopener" className="hover:text-foreground">
                  {name}
                </a>
              ) : (
                name
              )}
            </li>
          ))}
        </ul>
      </div>
      <p id="store-soon" role="status" aria-live="polite" className={cn('text-sm font-medium', soon ? 'mt-4' : 'sr-only')}>
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
