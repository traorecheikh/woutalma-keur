import { motion } from 'motion/react';
import { QrCode, StoreBadges } from '@/components/store-badges';
import { install } from '@/content/fr';
import { site } from '@/site.config';

const ease = [0.22, 1, 0.36, 1] as const;

export function Install() {
  return (
    <section id="installer" className="scroll-mt-14">
      <div className="mx-auto max-w-[80rem] px-6 py-20 lg:py-28">
        <div className="grid gap-x-12 gap-y-10 lg:grid-cols-12">
          <div className="lg:col-span-7">
            <h2 className="heading max-w-[14ch]">{install.title}</h2>
            <p className="mt-5 max-w-[36rem] text-lg text-muted-foreground">{install.lead(site.version)}</p>
            <StoreBadges className="mt-8" />
          </div>
          <div className="lg:col-span-4 lg:col-start-9 lg:justify-self-end">
            <QrCode />
          </div>
        </div>
        <ol className="mt-14 grid gap-x-8 gap-y-8 border-t-2 border-foreground pt-8 sm:grid-cols-3">
          {install.steps.map((s, i) => (
            <motion.li
              key={s.title}
              initial={{ opacity: 0, y: 8 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.3 }}
              transition={{ duration: 0.5, delay: i * 0.08, ease }}
            >
              <span className="tabular text-sm font-semibold text-muted-foreground">{String(i + 1).padStart(2, '0')}</span>
              <h3 className="mt-3 text-lg font-semibold">{s.title}</h3>
              <p className="mt-1.5 max-w-[40ch] leading-relaxed text-muted-foreground">{s.body}</p>
            </motion.li>
          ))}
        </ol>
      </div>
      <img
        src={install.photo.src}
        alt={install.photo.alt}
        width={1200}
        height={800}
        loading="lazy"
        className="h-[clamp(10rem,28svh,18rem)] w-full border-t-2 border-brand-orange object-cover"
      />
    </section>
  );
}
