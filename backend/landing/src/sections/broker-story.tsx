import { useReducedMotion } from 'motion/react';
import { InfiniteSlider } from '@/components/ui/infinite-slider';
import { Android } from '@/components/ui/android';
import { Eyebrow, PhoneStory } from '@/components/phone-story';
import { brokerStory } from '@/content/fr';

export function BrokerStory() {
  const reduced = useReducedMotion();
  return (
    <section id="courtiers" className="scroll-mt-14 bg-primary text-primary-foreground">
      <div className="mx-auto max-w-[80rem] px-6 pt-24 pb-8 lg:pt-32">
        <Eyebrow className="text-on-blue-secondary">{brokerStory.eyebrow}</Eyebrow>
        <h2 className="heading mt-4 max-w-[18ch]">{brokerStory.title}</h2>
        <p className="mt-6 max-w-[38rem] text-lg leading-relaxed text-on-blue-secondary">{brokerStory.lead}</p>
        <div className="mt-8">
          <PhoneStory steps={brokerStory.steps} tone="blue" />
        </div>
      </div>
      <div className="border-t border-white/15 py-12">
        {reduced ? (
          <ul className="mx-auto flex max-w-[80rem] gap-6 overflow-x-auto px-6">
            {brokerStory.slider.map((s) => (
              <li key={s.src} className="w-[200px] shrink-0">
                <Android src={s.src} alt={s.alt} />
              </li>
            ))}
          </ul>
        ) : (
          <InfiniteSlider gap={24} speed={40}>
            {brokerStory.slider.map((s) => (
              <div key={s.src} className="w-[200px]">
                <Android src={s.src} alt={s.alt} />
              </div>
            ))}
          </InfiniteSlider>
        )}
      </div>
    </section>
  );
}
