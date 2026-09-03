import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { LegalPage } from '@/components/legal-page';
import { legal } from '@/content/legal';
import './index.css';

const root = document.getElementById('root')!;
const page = legal[root.dataset.page as keyof typeof legal];

createRoot(root).render(
  <StrictMode>
    <LegalPage {...page} />
  </StrictMode>,
);
