import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react-swc';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';

const p = (s: string) => fileURLToPath(new URL(s, import.meta.url));

export default defineConfig({
  root: p('.'),
  base: '/',
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': p('src') } },
  build: {
    outDir: p('../landing-dist'),
    emptyOutDir: true,
    rollupOptions: {
      input: {
        index: p('index.html'),
        confidentialite: p('confidentialite/index.html'),
        conditions: p('conditions/index.html'),
        'a-propos': p('a-propos/index.html'),
      },
    },
  },
  server: { port: 5174, fs: { allow: [p('..'), p('../../assets/fonts')] } },
});
