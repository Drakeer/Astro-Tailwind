// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// Static output only — nginx serves dist/ directly. No adapter, no SSR.
export default defineConfig({
  site: 'https://arcrayde.com',
  output: 'static',
  vite: {
    plugins: [tailwindcss()],
  },
});
