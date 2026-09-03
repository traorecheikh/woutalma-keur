import { Eyebrow, PhoneStory } from '@/components/phone-story';
import { clientStory } from '@/content/fr';

export function ClientStory() {
  return (
    <section id="clients" className="mx-auto max-w-[80rem] scroll-mt-14 px-6 pt-32 pb-8 lg:pt-40">
      <Eyebrow>{clientStory.eyebrow}</Eyebrow>
      <h2 className="heading mt-4 max-w-[16ch]">{clientStory.title}</h2>
      <div className="mt-8">
        <PhoneStory steps={clientStory.steps} />
      </div>
    </section>
  );
}
