import { motion } from 'motion/react';
import { Android } from '@/components/ui/android';
import { Eyebrow } from '@/components/section-label';
import { brokerStory } from '@/content/fr';

const ease = [0.22, 1, 0.36, 1] as const;
const title = brokerStory.title.split('. ').join('.\n');

export function BrokerStory() {
  return (
    <section id="courtiers" className="scroll-mt-14 bg-secondary">
      <div className="mx-auto max-w-[80rem] px-6 pt-20 pb-12 lg:pt-28">
        <div className="grid gap-x-12 gap-y-6 lg:grid-cols-12">
          <div className="lg:col-span-6">
            <Eyebrow>{brokerStory.eyebrow}</Eyebrow>
            <h2 className="heading mt-5 whitespace-pre-line">{title}</h2>
          </div>
          <p className="text-lg leading-relaxed text-muted-foreground lg:col-span-5 lg:col-start-8 lg:self-end">{brokerStory.lead}</p>
        </div>
        <ol className="mt-14 border-b border-foreground/15">
          {brokerStory.steps.map((step, i) => (
            <motion.li
              key={step.title}
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.25 }}
              transition={{ duration: 0.5, ease }}
              className="grid items-center gap-x-8 gap-y-6 border-t border-foreground/15 py-10 lg:grid-cols-12"
            >
              <div className="lg:col-span-7">
                <span className="tabular text-sm font-semibold text-muted-foreground">{String(i + 1).padStart(2, '0')}</span>
                <h3 className="mt-3 max-w-[20ch] text-2xl leading-tight font-bold lg:text-3xl">{step.title}</h3>
                <p className="mt-3 max-w-[44ch] leading-relaxed text-muted-foreground">{step.body}</p>
              </div>
              <div className="w-[min(170px,50%)] lg:col-span-3 lg:col-start-10 lg:w-full lg:max-w-[170px] lg:justify-self-end">
                <Android src={step.screen} alt={step.alt} />
              </div>
            </motion.li>
          ))}
        </ol>
      </div>
      <div className="bg-ink py-10">
        <ul className="mx-auto flex max-w-[80rem] gap-6 overflow-x-auto px-6">
          {brokerStory.slider.map((s) => (
            <li key={s.src} className="w-[150px] shrink-0">
              <Android src={s.src} alt={s.alt} />
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
