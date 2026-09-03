import { InView } from '@/components/ui/in-view';
import { Eyebrow } from '@/components/phone-story';
import { trust } from '@/content/fr';

const ease = [0.22, 1, 0.36, 1] as const;

export function Trust() {
  return (
    <section className="bg-ink text-on-ink">
      <div className="mx-auto max-w-[80rem] px-6 py-24 lg:py-32">
        <Eyebrow className="text-on-ink-secondary">{trust.eyebrow}</Eyebrow>
        <h2 className="heading mt-4 max-w-[16ch]">{trust.title}</h2>
        <ol className="mt-16 divide-y divide-hairline-ink border-y border-hairline-ink">
          {trust.rules.map((rule, i) => (
            <InView
              key={rule}
              as="li"
              once
              viewOptions={{ margin: '0px 0px -15% 0px' }}
              variants={{ hidden: { opacity: 0, y: 16 }, visible: { opacity: 1, y: 0 } }}
              transition={{ duration: 0.6, delay: i * 0.08, ease }}
            >
              <div className="grid gap-4 py-8 lg:grid-cols-12 lg:py-10">
                <span className="tabular text-sm font-semibold text-on-ink-secondary lg:col-span-1">{String(i + 1).padStart(2, '0')}</span>
                <p className="rule max-w-[26ch] lg:col-span-10">{rule}</p>
              </div>
            </InView>
          ))}
        </ol>
      </div>
    </section>
  );
}
