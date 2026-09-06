import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { nav } from '@/content/fr';
import { site } from '@/site.config';

export function Nav() {
  return (
    <header className="sticky top-0 z-20 border-b bg-background">
      <div className="mx-auto flex h-14 max-w-[80rem] items-center gap-5 px-6">
        <a href="/" className="text-lg font-bold tracking-tight">
          {site.name}
        </a>
        <Separator orientation="vertical" className="hidden !h-4 sm:block" />
        <p className="hidden text-sm text-muted-foreground sm:block">{site.tagline}</p>
        <nav aria-label="Sections" className="ml-auto hidden items-center gap-8 text-sm font-semibold lg:flex">
          {nav.links.map((l) => (
            <a key={l.href} href={l.href} className="text-muted-foreground hover:text-foreground">
              {l.label}
            </a>
          ))}
        </nav>
        <Button asChild size="lg" className="ml-auto h-10 px-4 text-sm font-semibold lg:ml-0">
          <a href="/#installer">{nav.download}</a>
        </Button>
      </div>
    </header>
  );
}
