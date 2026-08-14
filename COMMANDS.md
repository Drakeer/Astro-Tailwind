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

## SSH key + remote push setup (2026-08-13)

The remote (`github.com/Drakeer/Astro-Tailwind`) was reachable read-only but had
no write credentials on the VPS — no `gh` CLI, no `~/.ssh`, no credential helper —
so `git push` failed with "could not read Username for 'https://github.com'".

```bash
ssh-keygen -t ed25519 -C "drakes2005@gmail.com" -f ~/.ssh/id_ed25519 -N ""
```
Generates an Ed25519 SSH keypair. Ed25519 over RSA: shorter keys, faster, and the
current default recommendation. `-N ""` sets an empty passphrase so pushes can run
unattended — the trade-off is that anyone who can read the private key file can push,
so this key is scoped to one repo (see deploy key below) rather than the whole account.

```bash
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519
```
SSH refuses to use a private key that other users can read. `700` on the directory
and `600` on the key are the required permissions.

```bash
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
```
Fetches GitHub's host key ahead of time so the first connection doesn't stop on an
interactive "authenticity of host can't be established" prompt — which would hang a
non-interactive script. The result was verified against GitHub's published fingerprint
`SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU` before trusting it; blindly
appending a scanned host key otherwise defeats the point of host verification.

```bash
git remote set-url origin git@github.com:Drakeer/Astro-Tailwind.git
```
Switches the remote from HTTPS to SSH. HTTPS would still ask for a username/password
(and GitHub no longer accepts passwords); SSH uses the keypair above.

```bash
ssh -o BatchMode=yes -T git@github.com
```
Tests authentication without opening a shell. The reply
`Hi Drakeer/Astro-Tailwind! You've successfully authenticated...` confirms the key is
registered as a **deploy key on this repo**. An account-wide key would instead reply
`Hi Drakeer!` — a useful way to tell which kind of key is in play, since a deploy key
grants access to one repo while an account key grants it to every repo you own.
`BatchMode=yes` makes it fail immediately instead of prompting.

```bash
git push --dry-run origin <branch>
```
Shows exactly what a push *would* do without sending anything. Used here to confirm the
deploy key actually had write access ticked, before relying on it.

### Getting the public key from the VPS to a Mac browser

`~` in a remote SSH command expands to the *remote* login user's home. Logging in as
`ubuntu` while the key lives under `/home/claude-agent/` means `~/.ssh/id_ed25519.pub`
silently resolves to the wrong path — and `/home/claude-agent` is mode `750`, so it
isn't readable from the `ubuntu` account without `sudo` anyway.

```bash
ssh -i <key.pem> ubuntu@<host> 'cat /tmp/eric-github-key.pub' | pbcopy
```
Runs `cat` on the VPS and pipes the output into the Mac's clipboard. `pbcopy` is
macOS-local, so this crosses the remote/local clipboard boundary that a terminal
copy command cannot. An absolute path avoids the `~` expansion problem above.

```bash
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```
Prints the key's fingerprint (`SHA256:Jc7vGCbxGzAynJLQ2dM/xNfb4ulez+YaEv3wBNj2U38`).
GitHub shows the same fingerprint next to an added key, so comparing them catches a
truncated or line-wrapped paste — the usual failure when copying a long key out of a
terminal window.

## nginx: serving the built site (2026-08-13)

nginx serves the static `dist/` output directly. No Node process runs in
production — Astro's build is plain HTML/CSS/JS on disk.

The live configuration lives in `/etc/nginx/`, which is outside this repo, so
copies are vendored into `deploy/nginx/` to keep them version-controlled.
Those copies are reference material: editing them changes nothing until they
are copied back to `/etc/nginx/` and nginx is reloaded.

```bash
sudo apt-get install -y nginx
```
Installs nginx and enables the service.

```bash
sudo ln -s /etc/nginx/sites-available/<site> /etc/nginx/sites-enabled/<site>
```
Debian/Ubuntu convention: every vhost lives in `sites-available/`, and a
symlink into `sites-enabled/` is what actually activates it. Removing the
symlink disables a site without deleting its config.

```bash
sudo nginx -t
```
Parses the whole config and reports errors *without* applying it. Always run
before a reload — a syntax error in a reload can otherwise take the site down.

```bash
sudo systemctl reload nginx
```
Re-reads the config and gracefully hands connections to new workers. Unlike
`restart`, in-flight requests are not dropped.

```bash
curl -sS -H "Host: arcrayde.com" http://127.0.0.1/
```
Tests a name-based vhost before DNS points anywhere. nginx picks the server
block by the `Host` header, not by IP, so overriding the header reaches the
site locally. Requesting the bare IP instead hits the catch-all and returns
nothing — see below.

### Why the bare IP returns an empty reply

`000-catch-all` is the `default_server` and answers any request whose `Host`
matches no `server_name` — including requests to the raw IP address. It does
`return 444`, an nginx-specific code meaning "close the connection with no
response at all". So `http://<public-ip>/` producing `curl: (52) Empty reply
from server` is correct behaviour, not a fault. The site answers only to
`Host: arcrayde.com`.

Without a catch-all the *first* server block loaded becomes the implicit
default, which would let arcrayde.com be served under any hostname pointed at
this IP.

### Two things that will bite on going live

- The EC2 public IP changes on every stop/start. It moved from
  `54.159.196.213` to `54.84.230.185` after one restart. Allocate an
  **Elastic IP** before creating a DNS A record, or the record breaks on the
  next reboot.
- The AWS security group and `ufw` are independent layers and a port must be
  open in **both**. `ufw` already allows 80/443; the security group still has
  to be opened to `0.0.0.0/0` for those two ports (never 22) before the public
  can reach the site.
