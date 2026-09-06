import { SealCheck } from '@phosphor-icons/react';
import { InView } from '@/components/ui/in-view';
import { Eyebrow } from '@/components/section-label';
import { trust } from '@/content/fr';

const ease = [0.22, 1, 0.36, 1] as const;

export function Trust() {
  return (
    <section className="bg-primary text-primary-foreground">
      <div className="mx-auto max-w-[80rem] px-6 py-20 lg:py-28">
        <div className="grid gap-x-12 gap-y-6 lg:grid-cols-12">
          <div className="lg:col-span-6">
            <Eyebrow tone="light">{trust.eyebrow}</Eyebrow>
            <h2 className="heading mt-5 max-w-[16ch]">{trust.title}</h2>
          </div>
        </div>
        <ol className="mt-14 grid gap-x-12 gap-y-10 sm:grid-cols-2">
          {trust.rules.map((rule, i) => (
            <InView
              key={rule}
              as="li"
              once
              viewOptions={{ margin: '0px 0px -10% 0px' }}
              variants={{ hidden: { opacity: 0, y: 12 }, visible: { opacity: 1, y: 0 } }}
              transition={{ duration: 0.5, delay: (i % 2) * 0.1, ease }}
            >
              <div className="flex gap-4 border-t border-white/30 pt-6">
                <SealCheck className="mt-1 size-6 shrink-0" weight="fill" aria-hidden />
                <p className="max-w-[28ch] text-xl leading-snug font-semibold lg:text-2xl">{rule}</p>
              </div>
            </InView>
          ))}
        </ol>
      </div>
    </section>
  );
}
