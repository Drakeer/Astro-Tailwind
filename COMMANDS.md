# Command Log

Every command run on this project, with a short explanation. Kept for learning purposes — updated as the project progresses.

## Git setup

```bash
git config user.name "drakeer"
git config user.email "drakes2005@gmail.com"
```
Sets the commit author identity for this repo only (no `--global`, so it doesn't affect other projects on this machine).

```bash
git add <file>
```
Stages a file's changes so the next `git commit` includes it.

```bash
git commit -m "message"
```
Records staged changes as a new commit with the given message.

```bash
git reset --soft <commit>
```
Moves the branch pointer back to `<commit>` without touching the working tree or staged files — used here to squash two separate commits (CLAUDE.md, then .gitignore) into one combined "Initial Setup" commit.

```bash
git commit --amend --reset-author -m "message"
```
Replaces the most recent commit with a new one, re-stamping the author/committer to whatever is currently in `git config` (used to fix authorship after setting identity late) and setting a new message.

```bash
git merge --ff-only <branch>
```
Fast-forwards the current branch to match `<branch>`, only if no divergent history exists (no merge commit created). Used to bring work from an isolated worktree branch onto `master`.

## Node.js installation (Ubuntu 26.04 VPS)

Installed via NodeSource's current recommended method: an apt repo pinned with a GPG keyring (the older `curl | sudo bash` setup script is deprecated by NodeSource for security reasons — piping a downloaded script straight into a root shell is riskier than a verified, versioned apt source).

```bash
sudo apt-get update -y
```
Refreshes the local package index from all configured apt repos.

```bash
sudo apt-get install -y ca-certificates curl gnupg
```
Installs tools needed for the next steps: `ca-certificates` (trust HTTPS certs), `curl` (download the GPG key), `gnupg` (verify/convert it).

```bash
sudo mkdir -p /etc/apt/keyrings
```
Creates the standard directory apt uses for repo-specific signing keys (modern replacement for the old global `apt-key` approach).

```bash
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /tmp/nodesource.gpg.key
```
Downloads NodeSource's public signing key. `-fsSL` = fail silently on HTTP errors, silent progress, follow redirects.

```bash
sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg /tmp/nodesource.gpg.key
```
Converts the key from ASCII-armored text to the binary format apt expects, saving it where apt will look for it.

```bash
echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main' | sudo tee /etc/apt/sources.list.d/nodesource.list
```
Registers the NodeSource repo for Node.js 24.x (current Active LTS) as an apt source, tied to the key above so apt only trusts packages signed by NodeSource.

```bash
sudo apt-get update -y
```
Re-syncs the package index, now including the new NodeSource repo.

```bash
sudo apt-get install -y nodejs
```
Installs Node.js — npm comes bundled with it, no separate install needed.

## Verification

```bash
which node
which npm
```
Prints the full path of each binary, confirming they're installed and on `PATH`.

```bash
node -v
npm -v
```
Prints installed version numbers — confirmed `v24.19.0` (node) and `11.17.0` (npm).

## Astro + Tailwind project scaffold

```bash
npm create astro@latest <dir> -- --template minimal --no-install --no-git --yes
```
Runs Astro's official scaffolding CLI (`create-astro`) and generates the `minimal` starter template into `<dir>`. `--no-install` skips `npm install` (done separately, after moving files into place), `--no-git` skips `git init` (this repo already has one), `--yes` accepts defaults non-interactively. Scaffolded into a scratch directory rather than straight into the project root because `create-astro` refuses to write into a non-empty directory — it silently redirects to a new randomly-named subfolder instead of erroring, so a temp dir + manual move avoids that surprise.

```bash
mv <scratch-dir>/<file-or-dir> .
```
Moved only the actual Astro project files (`package.json`, `astro.config.mjs`, `tsconfig.json`, `src/`, `public/`, `.vscode/`) into the real project directory — deliberately *not* moving the scaffold's own generic `.gitignore`, `README.md`, or `AGENTS.md`/`CLAUDE.md` (a symlink to it), since those would've overwritten the project-specific versions already in place.

```bash
npm install
```
Installs everything listed in `package.json` (just `astro` at this point) into `node_modules/`.

```bash
npm install astro@5.18.2
```
Pins Astro to the latest 5.x release. `npm create astro@latest` installs whatever's tagged `latest` on npm — that's now Astro 7 — so this overrides it to stay on the requested major version (5).

```bash
npm install tailwindcss @tailwindcss/vite
```
Installs Tailwind CSS v4 and its official Vite plugin — the current recommended way to use Tailwind v4 in Astro. (Older setups used the `@astrojs/tailwind` integration or a separate `postcss.config`/`tailwind.config.js`; both are unnecessary/deprecated under v4.)

```bash
npm run build
```
Builds the static site to `dist/` — used here to verify the Astro + Tailwind wiring actually works (confirmed Tailwind utility classes like `text-3xl` were compiled into the output CSS and linked from `index.html`).

## Portfolio site build (2026-08-13)

```bash
git config user.name "Drakeer"
git config user.email "drakes2005@gmail.com"
```
Re-set the repo-local commit identity. Note this stamps `Drakeer` (capital D) while last night's commits used `drakeer` — Git treats those as different author names, so the log now shows both spellings.

```bash
npm run preview -- --port 4399
```
Serves the built `dist/` locally to sanity-check before deploy. The explicit port matters: the default 4321 was already occupied, and `astro preview` silently falls back to 4322 rather than failing. A naive `curl localhost:4321` therefore hit an unrelated server and returned a misleading 200.

```bash
curl -s -o /dev/null -w "HTTP %{http_code} / %{size_download} bytes\n" http://localhost:4399/
```
Confirms the preview actually serves the real page — status code plus byte count, so a wrong-server response is visible instead of being assumed correct.

```bash
grep -o "\.bg-void\|\.text-accent" dist/_astro/*.css | sort | uniq -c
```
Verifies that custom Tailwind v4 `@theme` tokens compiled into real utility classes. Under v4 a token typo produces no build error — the utility is simply never generated and the page renders unstyled — so this is checked explicitly rather than trusted.

## Reconciling two unrelated histories (2026-08-13)

The repo ended up with two root commits and no shared ancestor: `master`
(root `841fd23`, authored before the identity was set) and `main` (root
`3d9eb38`, the clean squashed history). `main` carries the better CLAUDE.md,
this command log, the favicons and `.vscode/` config.

```bash
git merge-base main master; echo "exit=$?"
```
Tests whether two branches share a common ancestor. Exit code 1 with no output means they do not — the histories are unrelated, so an ordinary `git merge` would refuse without `--allow-unrelated-histories`, and a rebase would be equally messy. Porting the files across is cleaner than forcing the graphs together.

```bash
git worktree add -b reconcile/portfolio-on-main <path> main
```
Creates a new branch off `main` in its own checkout, so the port is assembled and built in isolation without disturbing `main` itself.
