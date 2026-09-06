import { useEffect, useRef, useState } from 'react';
import { motion, useInView, useReducedMotion } from 'motion/react';
import { TextEffect } from '@/components/ui/text-effect';
import { Android } from '@/components/ui/android';
import { Eyebrow } from '@/components/section-label';
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
    <section>
      <div className="mx-auto max-w-[80rem] px-6 py-20 lg:py-28">
        <div className="grid gap-x-12 gap-y-6 lg:grid-cols-12">
          <div className="lg:col-span-6">
            <Eyebrow>{access.eyebrow}</Eyebrow>
            <h2 className="heading mt-5 max-w-[16ch]">{access.title}</h2>
          </div>
          <p className="text-lg leading-relaxed text-muted-foreground lg:col-span-5 lg:col-start-8 lg:self-end">{access.body}</p>
        </div>
        <div className="mt-12 grid gap-10 border-t pt-12 lg:grid-cols-12 lg:items-center">
          <div className="lg:col-span-8">
            <SpokenDemo />
          </div>
          <div className="mx-auto w-[min(190px,55%)] lg:col-span-3 lg:col-start-10 lg:mx-0 lg:w-full lg:max-w-[190px] lg:justify-self-end">
            <Android src={access.screen.src} alt={access.screen.alt} />
          </div>
        </div>
      </div>
      <img
        src={access.photo.src}
        alt={access.photo.alt}
        width={1200}
        height={800}
        loading="lazy"
        className="h-[clamp(10rem,28svh,18rem)] w-full border-t-2 border-brand-orange object-cover"
      />
    </section>
  );
}
