import { useEffect, useRef, useState } from 'react';
import { motion, useInView, useReducedMotion } from 'motion/react';
import { TextEffect } from '@/components/ui/text-effect';
import { Android } from '@/components/ui/android';
import { Eyebrow } from '@/components/phone-story';
import { access } from '@/content/fr';

const words = access.spoken.split(' ').length;
const readingSeconds = words * 0.32;

// Démo de lecture : les mots apparaissent au rythme d'une voix, le trait suit, puis ça recommence.
function SpokenDemo() {
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { amount: 0.5 });
  const reduced = useReducedMotion();
  const [cycle, setCycle] = useState(0);

  useEffect(() => {
    if (!inView || reduced) return;
    const id = setInterval(() => setCycle((c) => c + 1), (readingSeconds + 2.5) * 1000);
    return () => clearInterval(id);
  }, [inView, reduced]);

  if (reduced) {
    return (
      <div ref={ref} className="border-l-2 border-primary pl-5">
        <p className="rule text-foreground">{access.spoken}</p>
      </div>
    );
  }

  return (
    <div ref={ref} className="relative">
      <div className="pl-5">
        <TextEffect key={cycle} as="p" per="word" preset="fade" trigger={inView} speedReveal={0.16} className="rule text-foreground">
          {access.spoken}
        </TextEffect>
      </div>
      <motion.span
        key={`bar-${cycle}`}
        aria-hidden
        className="absolute top-0 left-0 h-full w-0.5 origin-top bg-primary"
        initial={{ scaleY: 0 }}
        animate={inView ? { scaleY: 1 } : { scaleY: 0 }}
        transition={{ duration: readingSeconds, ease: 'linear' }}
      />
    </div>
  );
}

export function Accessibility() {
  return (
    <section className="mx-auto grid max-w-[80rem] gap-12 px-6 py-24 lg:grid-cols-12 lg:py-32">
      <div className="lg:col-span-6">
        <Eyebrow>{access.eyebrow}</Eyebrow>
        <h2 className="heading mt-4 max-w-[16ch]">{access.title}</h2>
        <p className="mt-6 max-w-[38rem] text-lg leading-relaxed text-muted-foreground">{access.body}</p>
        <div className="mt-12">
          <SpokenDemo />
        </div>
      </div>
      <div className="relative lg:col-span-5 lg:col-start-8">
        <img src={access.photo.src} alt={access.photo.alt} width={1200} height={800} loading="lazy" className="aspect-[4/5] w-full rounded-md object-cover" />
        <div className="absolute inset-x-0 -bottom-8 mx-auto w-[58%] max-w-[280px]">
          <Android src={access.screen.src} alt={access.screen.alt} />
        </div>
      </div>
    </section>
  );
}
