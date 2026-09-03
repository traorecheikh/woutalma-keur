import { motion } from 'motion/react';
import { TextAnimate } from '@/components/ui/text-animate';
import { Android } from '@/components/ui/android';
import { StoreBadges } from '@/components/store-badges';
import { hero } from '@/content/fr';
import { site } from '@/site.config';

const ease = [0.22, 1, 0.36, 1] as const;

export function Hero() {
  return (
    <section className="mx-auto grid max-w-[80rem] items-end gap-12 px-6 pt-16 pb-24 lg:min-h-[calc(100svh-3.5rem)] lg:grid-cols-12 lg:py-16">
      <div className="lg:col-span-7">
        <TextAnimate as="h1" by="word" animation="fadeIn" duration={0.7} className="display max-w-[12ch]">
          {hero.title}
        </TextAnimate>
        <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5, delay: 0.4, ease }}>
          <p className="mt-8 max-w-[34rem] text-xl leading-relaxed text-muted-foreground">{hero.lead}</p>
          <StoreBadges className="mt-10" />
          <p className="mt-4 text-sm text-muted-foreground">
            {hero.caption(site.version)}{' '}
            <a href="#clients" className="font-semibold text-primary underline underline-offset-4">
              {hero.secondary}
            </a>
          </p>
        </motion.div>
      </div>
      <motion.div
        initial={{ opacity: 0, y: 32 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.2, ease }}
        className="relative mx-auto w-full max-w-[420px] lg:col-span-5 lg:col-start-8 lg:max-w-none"
      >
        <img src={hero.photo.src} alt={hero.photo.alt} width={1200} height={800} className="aspect-[4/5] w-full rounded-md object-cover" />
        <div className="absolute inset-x-0 -bottom-10 mx-auto w-[58%] max-w-[280px]">
          <Android src={hero.screen.src} alt={hero.screen.alt} />
        </div>
      </motion.div>
    </section>
  );
}
