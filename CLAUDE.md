# Portfolio site (arcrayde.com)

Personal portfolio/developer site.

## Stack
- **Astro 5** (static output — default, no `output:` set explicitly since `static` is Astro's default; no SSR/adapter). Pinned to `^5.18.2` in `package.json` — `npm create astro@latest` defaults to Astro 7 now, deliberately not used here.
- **Tailwind CSS v4** for styling, wired via the `@tailwindcss/vite` plugin in `astro.config.mjs` — not the old `@astrojs/tailwind` integration or a `tailwind.config.js`/postcss setup, both deprecated for v4.
  - Global stylesheet: `src/styles/global.css` (just `@import "tailwindcss";`)
  - Imported once in `src/layouts/Layout.astro`, which every page should use so styles apply site-wide
- Plain HTML/CSS output, no client-side framework unless a specific interactive component needs Astro islands (prefer plain JS/CSS first)

## Commands
- `npm run dev` — local dev server
- `npm run build` — outputs static site to `dist/`
- `npm run preview` — serve the built `dist/` locally to sanity-check before deploy

## Conventions
- Pages live in `src/pages/` (file-based routing)
- Shared UI in `src/components/`, layouts in `src/layouts/` (currently just `Layout.astro`, the base layout every page wraps in)
- Use `.astro` components by default; only reach for a UI framework if truly needed (none installed currently — don't add React/Vue/etc. without asking)
- Tailwind utility classes inline; avoid custom CSS files unless something isn't expressible in utilities
- Keep dependencies minimal — this is a static portfolio, not an app

## Deployment
- No Docker, no Node server in production — **static files only**
- Build locally/in CI (`npm run build`), then sync `dist/` to the VPS
- **nginx** serves `dist/` directly as static files for `arcrayde.com`
- After any deploy, confirm nginx's `root` points at the new `dist/` contents and reload nginx if config changed (`nginx -t && systemctl reload nginx`)
- No environment variables / secrets expected at runtime (static site) — if a build-time env var is introduced, document it here

## When making changes
- Run `npm run build` before considering a task done — this is the only thing that has to work in production
- Don't introduce SSR-only Astro features (API routes, `output: 'server'`, adapters) — breaks the static/nginx deploy model
