import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react-swc';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';

const adminRoot = fileURLToPath(new URL('.', import.meta.url));

export default defineConfig({
  root: adminRoot,
  base: '/admin/',
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': fileURLToPath(new URL('src', import.meta.url)) } },
  build: { outDir: fileURLToPath(new URL('../admin-dist', import.meta.url)), emptyOutDir: true },
  server: { proxy: { '/admin-api': 'http://localhost:3000' } },
});
