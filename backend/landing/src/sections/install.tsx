import { motion } from 'motion/react';
import { QrCode, StoreBadges } from '@/components/store-badges';
import { install } from '@/content/fr';
import { site } from '@/site.config';

const ease = [0.22, 1, 0.36, 1] as const;

export function Install() {
  return (
    <section id="installer" className="mx-auto grid max-w-[80rem] gap-12 px-6 py-24 scroll-mt-14 lg:grid-cols-12 lg:py-32">
      <div className="lg:col-span-5">
        <h2 className="heading max-w-[14ch]">{install.title}</h2>
        <p className="mt-5 max-w-[36rem] text-xl text-muted-foreground">{install.lead(site.version)}</p>
        <StoreBadges className="mt-8" />
        <QrCode className="mt-10" />
      </div>
      <div className="lg:col-span-6 lg:col-start-7">
        <ol className="divide-y border-y">
          {install.steps.map((s, i) => (
            <motion.li
              key={s.title}
              initial={{ opacity: 0, y: 8 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.3 }}
              transition={{ duration: 0.5, delay: i * 0.08, ease }}
              className="grid grid-cols-[3rem_1fr] gap-x-4 py-6"
            >
              <span className="tabular text-sm font-semibold text-muted-foreground">{String(i + 1).padStart(2, '0')}</span>
              <div>
                <h3 className="text-lg font-semibold">{s.title}</h3>
                <p className="mt-1.5 max-w-[48ch] text-muted-foreground">{s.body}</p>
              </div>
            </motion.li>
          ))}
        </ol>
        <img src={install.photo.src} alt={install.photo.alt} width={1200} height={800} loading="lazy" className="mt-12 aspect-[16/9] w-full rounded-md object-cover" />
      </div>
    </section>
  );
}
