import { motion } from 'motion/react';
import { Android } from '@/components/ui/android';
import { Eyebrow } from '@/components/section-label';
import { clientStory } from '@/content/fr';

const ease = [0.22, 1, 0.36, 1] as const;

export function ClientStory() {
  return (
    <section id="clients" className="mx-auto max-w-[80rem] scroll-mt-14 px-6 py-20 lg:py-28">
      <Eyebrow>{clientStory.eyebrow}</Eyebrow>
      <h2 className="heading mt-5 max-w-[16ch]">{clientStory.title}</h2>
      <ol className="mt-14 grid gap-x-8 gap-y-12 sm:grid-cols-3">
        {clientStory.steps.map((step, i) => (
          <motion.li
            key={step.title}
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.2 }}
            transition={{ duration: 0.5, delay: i * 0.1, ease }}
          >
            <div className="border-t-2 border-foreground pt-3">
              <span className="tabular text-sm font-semibold">{String(i + 1).padStart(2, '0')}</span>
            </div>
            <div className="mt-6 overflow-hidden bg-secondary px-8 pt-8">
              <Android src={step.screen} alt={step.alt} className="mx-auto -mb-10 block max-w-[210px]" />
            </div>
            <h3 className="mt-6 text-xl font-semibold">{step.title}</h3>
            <p className="mt-2 max-w-[36ch] leading-relaxed text-muted-foreground">{step.body}</p>
          </motion.li>
        ))}
      </ol>
    </section>
  );
}
