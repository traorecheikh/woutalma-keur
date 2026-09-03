import { EnvelopeSimple, WhatsappLogo } from '@phosphor-icons/react';
import { footer } from '@/content/fr';
import { site } from '@/site.config';

export function Footer() {
  const wa = site.whatsapp.replace(/\D/g, '');
  return (
    <footer className="bg-ink text-on-ink">
      <div className="mx-auto max-w-[80rem] px-6 py-16">
        <div className="grid gap-12 md:grid-cols-4">
          <div>
            <p className="text-lg font-bold">{site.name}</p>
            <p className="mt-2 text-on-ink-secondary">{site.tagline}</p>
          </div>
          {(wa || site.email) && (
            <div>
              <p className="text-sm font-semibold tracking-[0.04em] text-on-ink-secondary">{footer.contact}</p>
              <ul className="mt-4 space-y-3">
                {wa && (
                  <li>
                    <a href={`https://wa.me/${wa}`} className="inline-flex items-center gap-2 hover:text-white">
                      <WhatsappLogo className="size-5" aria-hidden />
                      {footer.whatsapp}
                    </a>
                  </li>
                )}
                {site.email && (
                  <li>
                    <a href={`mailto:${site.email}`} className="inline-flex items-center gap-2 hover:text-white">
                      <EnvelopeSimple className="size-5" aria-hidden />
                      {footer.email}
                    </a>
                  </li>
                )}
              </ul>
            </div>
          )}
          <div>
            <p className="text-sm font-semibold tracking-[0.04em] text-on-ink-secondary">{footer.legal}</p>
            <ul className="mt-4 space-y-3">
              {[['/confidentialite/', footer.privacy], ['/conditions/', footer.terms], ['/a-propos/', footer.about]].map(([href, label]) => (
                <li key={href}>
                  <a href={href} className="hover:text-white">
                    {label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <p className="text-sm font-semibold tracking-[0.04em] text-on-ink-secondary">{footer.credits}</p>
            <ul className="mt-4 space-y-2 text-sm text-on-ink-secondary">
              {site.photoCredits.map((c) => (
                <li key={c.file}>
                  <a href={c.href} rel="noopener" className="hover:text-white">
                    {c.author}
                  </a>
                  , {c.license}
                </li>
              ))}
            </ul>
          </div>
        </div>
        <div className="mt-16 flex flex-wrap items-center justify-between gap-4 border-t border-hairline-ink pt-6 text-sm text-on-ink-secondary">
          <p>
            © {new Date().getFullYear()} LIC · {footer.credit}
          </p>
          <p className="tabular">{footer.version(site.version)}</p>
        </div>
      </div>
    </footer>
  );
}
