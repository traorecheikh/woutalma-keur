import { useRef } from 'react';
import { motion, useReducedMotion, useScroll, useTransform, type MotionValue } from 'motion/react';
import { Android } from '@/components/ui/android';
import { cn } from '@/lib/utils';

export type Step = { title: string; body: string; screen: string; alt: string };

const ease = [0.22, 1, 0.36, 1] as const;
// Motion 13 pilote ces valeurs par ScrollTimeline : les offsets doivent rester dans [0,1].
const band = (n: number, ...ks: number[]) => ks.map((k) => Math.min(1, Math.max(0, k / n)));

export function Eyebrow({ children, className }: { children: string; className?: string }) {
  return (
    <p className={cn('text-sm font-semibold tracking-[0.04em]', className)}>
      <span aria-hidden className="mr-3 inline-block h-px w-6 translate-y-[-3px] bg-brand-orange" />
      {children}
    </p>
  );
}

// Téléphone épinglé : la colonne droite reste collée pendant que les étapes défilent à gauche.
export function PhoneStory({ steps, tone = 'paper' }: { steps: Step[]; tone?: 'paper' | 'ink' | 'blue' }) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start start', 'end end'] });
  const reduced = useReducedMotion();
  const n = steps.length;
  const muted = { paper: 'text-muted-foreground', ink: 'text-on-ink-secondary', blue: 'text-on-blue-secondary' }[tone];
  return (
    <div ref={ref} className="grid gap-8 lg:grid-cols-12">
      <ol className="lg:col-span-5">
        {steps.map((step, i) => (
          <StepItem key={step.title} step={step} i={i} n={n} progress={scrollYProgress} muted={muted} reduced={!!reduced} />
        ))}
      </ol>
      <div className="hidden lg:col-span-6 lg:col-start-7 lg:block">
        <div className="sticky top-0 flex h-svh items-center justify-center">
          <div className="relative w-[320px]">
            {steps.map((step, i) => (
              <Screen key={step.screen + i} step={step} i={i} n={n} progress={scrollYProgress} reduced={!!reduced} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function StepItem({ step, i, n, progress, muted, reduced }: { step: Step; i: number; n: number; progress: MotionValue<number>; muted: string; reduced: boolean }) {
  const lo = i === 0 ? 1 : 0.35;
  const hi = i === n - 1 ? 1 : 0.35;
  const opacity = useTransform(progress, band(n, i - 0.5, i, i + 1, i + 1.5), [lo, 1, 1, hi]);
  return (
    <li className="flex min-h-[80svh] items-center py-12 lg:py-0">
      <motion.div style={reduced ? undefined : { opacity }} className="w-full">
        <p className={cn('tabular text-sm font-semibold', muted)}>{String(i + 1).padStart(2, '0')}</p>
        <h3 className="rule mt-3 max-w-[22ch]">{step.title}</h3>
        <p className={cn('mt-4 max-w-[40ch] text-lg leading-relaxed', muted)}>{step.body}</p>
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.5, ease }}
          className="mt-8 max-w-[260px] lg:hidden"
        >
          <Android src={step.screen} alt={step.alt} />
        </motion.div>
      </motion.div>
    </li>
  );
}

function Screen({ step, i, n, progress, reduced }: { step: Step; i: number; n: number; progress: MotionValue<number>; reduced: boolean }) {
  const lo = i === 0 ? 1 : 0;
  const hi = i === n - 1 ? 1 : 0;
  const opacity = useTransform(progress, band(n, i - 0.3, i, i + 1, i + 1.3), [lo, 1, 1, hi]);
  const y = useTransform(progress, band(n, i - 0.3, i), [24, 0]);
  return (
    <motion.div style={reduced ? undefined : { opacity, y }} className={cn(i > 0 && 'absolute inset-0')} aria-hidden={i > 0}>
      <Android src={step.screen} alt={step.alt} />
    </motion.div>
  );
}
