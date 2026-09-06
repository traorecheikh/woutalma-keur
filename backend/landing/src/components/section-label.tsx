import { cn } from '@/lib/utils';

// Le filet orange passe sous le libellé ; sur le bleu de marque il vire au blanc, l'orange y est illisible.
export function Eyebrow({ children, className, tone = 'orange' }: { children: string; className?: string; tone?: 'orange' | 'light' }) {
  return (
    <p className={cn('text-sm font-semibold tracking-[0.04em]', className)}>
      {children}
      <span aria-hidden className={cn('mt-2 block h-0.5 w-10', tone === 'light' ? 'bg-current' : 'bg-brand-orange')} />
    </p>
  );
}
