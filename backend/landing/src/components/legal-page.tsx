import { Nav } from '@/components/nav';
import { Footer } from '@/components/footer';
import { site } from '@/site.config';

export type LegalSection = { title: string; paragraphs: string[]; list?: string[] };

export function LegalPage({ title, updated, intro, sections }: { title: string; updated: string; intro: string; sections: LegalSection[] }) {
  return (
    <>
      <Nav />
      <main className="mx-auto max-w-[80rem] px-6 py-16 lg:py-24">
        <p className="text-sm text-muted-foreground">
          <a href="/" className="hover:text-foreground">
            {site.name}
          </a>{' '}
          · Mis à jour le {updated}
        </p>
        <h1 className="heading mt-4 max-w-[20ch]">{title}</h1>
        <p className="mt-6 max-w-[65ch] text-xl leading-relaxed text-muted-foreground">{intro}</p>
        <div className="mt-16 grid gap-12 lg:grid-cols-12">
          <nav aria-label="Sommaire" className="lg:col-span-4">
            <ol className="sticky top-20 space-y-2 text-sm">
              {sections.map((s, i) => (
                <li key={s.title}>
                  <a href={`#s${i + 1}`} className="text-muted-foreground hover:text-foreground">
                    <span className="tabular mr-3">{String(i + 1).padStart(2, '0')}</span>
                    {s.title}
                  </a>
                </li>
              ))}
            </ol>
          </nav>
          <div className="divide-y lg:col-span-7 lg:col-start-6">
            {sections.map((s, i) => (
              <section key={s.title} id={`s${i + 1}`} className="scroll-mt-20 py-10 first:pt-0">
                <h2 className="text-2xl font-semibold tracking-[-0.01em]">
                  <span className="tabular mr-3 text-muted-foreground">{String(i + 1).padStart(2, '0')}</span>
                  {s.title}
                </h2>
                {s.paragraphs.map((p) => (
                  <p key={p} className="mt-4 max-w-[65ch] leading-relaxed text-muted-foreground">
                    {p}
                  </p>
                ))}
                {s.list && (
                  <ul className="mt-4 max-w-[65ch] list-disc space-y-2 pl-5 leading-relaxed text-muted-foreground">
                    {s.list.map((item) => (
                      <li key={item}>{item}</li>
                    ))}
                  </ul>
                )}
              </section>
            ))}
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}
