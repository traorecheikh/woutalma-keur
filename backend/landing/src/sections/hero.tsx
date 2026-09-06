import { motion } from 'motion/react';
import { TextAnimate } from '@/components/ui/text-animate';
import { StoreBadges } from '@/components/store-badges';
import { hero } from '@/content/fr';
import { site } from '@/site.config';

const ease = [0.22, 1, 0.36, 1] as const;
// Une phrase par ligne : c'est le rythme du titre, l'équilibrage automatique le cassait au milieu.
const title = hero.title.split('. ').join('.\n');

export function Hero() {
  return (
    <section className="grid lg:h-[min(44rem,calc(100svh-3.5rem))] lg:grid-cols-[1fr_42%]">
      <div className="flex flex-col justify-between px-6 py-14 lg:py-16 lg:pr-16 lg:pl-[max(1.5rem,calc((100vw-80rem)/2+1.5rem))]">
        <div>
          <motion.span
            aria-hidden
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ duration: 0.5, ease }}
            className="block h-0.5 w-10 origin-left bg-brand-orange"
          />
          <TextAnimate
            as="h1"
            by="line"
            animation="fadeIn"
            duration={0.9}
            className="mt-8 text-[clamp(2.5rem,1.4rem+3.2vw,4.5rem)] leading-[1.04] font-bold tracking-[-0.025em]"
          >
            {title}
          </TextAnimate>
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.35, ease }}
          >
            <p className="mt-7 max-w-[38ch] text-lg leading-relaxed text-muted-foreground lg:text-xl">{hero.lead}</p>
            <StoreBadges className="mt-9" />
          </motion.div>
        </div>
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.6, ease }}
          className="mt-12 flex flex-wrap items-baseline justify-between gap-x-8 gap-y-2 border-t pt-5 text-sm text-muted-foreground"
        >
          <p>{hero.caption(site.version)}</p>
          <a href="#clients" className="font-semibold text-primary underline underline-offset-4">
            {hero.secondary}
          </a>
        </motion.div>
      </div>
      <motion.img
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.9, ease }}
        src={hero.photo.src}
        alt={hero.photo.alt}
        width={1200}
        height={800}
        className="h-[42svh] w-full object-cover object-[50%_42%] lg:h-full"
      />
    </section>
  );
}
