import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { ReactLenis } from 'lenis/react';
import { MotionConfig } from 'motion/react';
import { ScrollProgress } from '@/components/ui/scroll-progress';
import { Nav } from '@/components/nav';
import { Footer } from '@/components/footer';
import { Hero } from '@/sections/hero';
import { ClientStory } from '@/sections/client-story';
import { Trust } from '@/sections/trust';
import { Accessibility } from '@/sections/accessibility';
import { BrokerStory } from '@/sections/broker-story';
import { Install } from '@/sections/install';
import './index.css';

function App() {
  return (
    <>
      <ScrollProgress className="fixed z-30 h-px bg-primary" />
      <Nav />
      <main>
        <Hero />
        <ClientStory />
        <Trust />
        <Accessibility />
        <BrokerStory />
        <Install />
      </main>
      <Footer />
    </>
  );
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ReactLenis root options={{ anchors: true }}>
      <MotionConfig reducedMotion="user">
        <App />
      </MotionConfig>
    </ReactLenis>
  </StrictMode>,
);
