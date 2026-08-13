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

## nginx — serving the built site over HTTP (port 80)

Ubuntu 26.04, nginx 1.28.3 from the distro repo. HTTP only; TLS comes later.

```bash
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
```
Installs nginx. `DEBIAN_FRONTEND=noninteractive` stops any package from opening an
interactive prompt mid-install, which would hang a non-tty session. The package
auto-enables and starts the service, so nginx is already listening on :80 afterwards.

```bash
nginx -V 2>&1 | tr ' ' '\n' | grep -E 'brotli|gzip_static|http_v2'
```
Lists which optional modules the binary was *compiled* with — you cannot enable a module
that isn't compiled in. Result: `http_v2` and `gzip_static` yes, **brotli no**. Brotli
beats gzip by ~15-20% on text but isn't in Ubuntu's build; it needs a third-party module
compiled from source, which is why gzip is still the right call here.

### The permission problem with serving out of $HOME

```bash
namei -l /home/claude-agent/sysadmin/portfolio/dist/index.html
```
Prints the ownership and mode of **every directory** along a path. This is the fast way
to diagnose an nginx 403: the worker runs as `www-data`, and it needs execute (`x`)
permission on every single directory in the chain, not just the final file.

It showed `/home/claude-agent` as `drwxr-x---` (750) — no `x` for "other", so `www-data`
could not traverse into it at all.

```bash
chmod o+x /home/claude-agent
sudo -u www-data test -r <path>/dist/index.html && echo YES
```
`o+x` (750 → 751) grants *traverse* only, not read or list. Another user can `cd` through
the directory and open a path they already know, but cannot `ls` to discover what's in it.
The second command verifies the fix by actually attempting the read **as** `www-data`
rather than assuming.

This is the tax for serving from a home directory, and it's exactly why nginx's convention
is `/var/www`. A tidier long-term layout: rsync `dist/` to `/var/www/arcrayde.com`, owned
`www-data:www-data`, and revert the home directory to 750.

### Why config went in conf.d/ instead of nginx.conf

`/etc/nginx/nginx.conf` is a dpkg *conffile*. Editing it makes every future
`apt upgrade` of nginx stop and ask you to merge your version against the new one.
`conf.d/*.conf` is included inside `http{}` (nginx.conf line 60) and is upgrade-safe,
so global settings live there instead.

Two directives had to stay in `nginx.conf` regardless, because **a directive cannot
appear twice in the same block**:

```bash
sudo nginx -t
# [emerg] "server_tokens" directive is duplicate in conf.d/10-hardening.conf:8
```
`server_tokens` was already set at nginx.conf:22 and `gzip on` at line 47. Redefining
either in `conf.d` is a fatal error, not an override. `server_tokens` was changed in
place (Ubuntu's own comment on that line invites it), and `gzip on` was left alone with
only the *tuning* directives added in `conf.d/20-gzip.conf`.

```bash
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig-backup
```
Keeps the pristine distro config to diff against later.

Files created:

| Path | Purpose |
| --- | --- |
| `/etc/nginx/conf.d/10-hardening.conf` | body-size cap, slow-client timeouts |
| `/etc/nginx/conf.d/20-gzip.conf` | gzip tuning (`gzip on` stays in nginx.conf) |
| `/etc/nginx/snippets/security-headers.conf` | all security headers, re-includable |
| `/etc/nginx/sites-available/arcrayde.com` | the site + www→apex redirect |
| `/etc/nginx/sites-available/000-catch-all` | `default_server` returning 444 |

### The add_header trap

nginx's `add_header` is **not cumulative across blocks**. Headers from an outer block are
inherited *only if the inner block declares no `add_header` of its own*. The instant a
`location` sets its own `Cache-Control`, every server-level security header silently
disappears for that location — no warning, no error, and `nginx -t` still passes.

That's why the headers live in a snippet that is `include`d again inside **every**
`location` that sets `Cache-Control`. Verify with curl per-location, never just on `/`.

### Cache strategy

Two classes of file, two very different rules:

- `/_astro/*` — filenames contain a content hash (`index.BRq_hIYa.css`), so the URL
  changes whenever the bytes do. Safe to cache forever:
  `public, max-age=31536000, immutable`. `immutable` also stops revalidation on reload.
- Everything else (`favicon.ico`, images) — same filename across deploys, so a one-year
  cache would leave no way to push an update. 7 days (`max-age=604800`).
- HTML — `no-cache`, which does *not* mean "don't cache". It means "cache, but always
  revalidate before reuse". nginx sends `ETag`, so an unchanged page costs a cheap 304
  and a deploy is picked up instantly. Caching HTML by time is how a deploy becomes
  invisible for hours.

### Verifying

```bash
sudo nginx -t && sudo systemctl reload nginx
```
Always test before reloading. `reload` re-reads config and cycles workers with no dropped
connections, unlike `restart`. Note that in-flight requests may still be served by the
*old* worker for a moment — a curl fired immediately after reload can show stale headers
and look like the config failed.

```bash
curl -sS -o /dev/null -D - -H 'Host: arcrayde.com' -H 'Accept-Encoding: gzip' http://127.0.0.1/
```
Tests locally without depending on DNS. `-D -` dumps response headers, `-o /dev/null`
discards the body. The `Host:` header is what nginx matches `server_name` against, so
this exercises the real server block over the loopback interface.

Reading the `ETag` is a quick way to confirm *which* file was served: `W/"6a7e0e7e-8f1d"`
ends in the size in hex — `0x8f1d` = 36637 bytes = our `index.html`. An unexpected 615
bytes means nginx is still serving `/var/www/html/index.nginx-debian.html`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' -H 'If-None-Match: "<etag>"' http://127.0.0.1/
```
Sends a conditional request. A `304` proves revalidation works and that repeat visits
cost almost nothing.

```bash
curl -sS http://127.0.0.1/ -o a; curl -sS -H 'Accept-Encoding: gzip' --raw http://127.0.0.1/ -o b
```
`--raw` tells curl **not** to transparently decompress, so the on-the-wire byte count can
be compared. Measured: HTML 36637 → 6729 B (81.6% saved), CSS 36184 → 7077 B (80.4%).

Verified behaviour:

| Request | Result |
| --- | --- |
| `/` | 200, `no-cache`, gzip, all security headers |
| `/_astro/*.css` | 200, `max-age=31536000, immutable` |
| `/favicon.ico` | 200, `max-age=604800` |
| conditional GET | 304 |
| `/nope` | 404 **with** security headers (the `always` flag) |
| unknown Host / bare IP | connection closed, no response (444) |
| `Host: www.arcrayde.com` | 301 → `http://arcrayde.com` preserving path + query |
| `/.env` | 403 |
| `/.well-known/acme-challenge/x` | 404, **not** 403 |

That last row matters: a blanket dotfile deny (`location ~ /\.`) is a classic way to break
certbot, whose HTTP-01 challenge is served from `/.well-known/`. The negative lookahead
`location ~ /\.(?!well-known)` blocks dotfiles while leaving that path reachable.

### Things deliberately not done yet

```bash
getent ahosts arcrayde.com     # -> 34.174.73.152
curl -sS https://api.ipify.org # -> 54.159.196.213 (this VPS)
```
**DNS does not point at this box.** The config is verified over loopback, but the site is
not publicly reachable at that name, and certbot's HTTP-01 challenge will fail until the
A record for `arcrayde.com` (and `www`) is repointed at the VPS.

`Strict-Transport-Security` is deliberately absent. It is meaningless over plain HTTP and
dangerous to set before TLS works: a browser that sees it will refuse to reach the site
over HTTP afterwards, locking you out of your own site. Add it in the HTTPS lesson,
starting with a short `max-age` until confident.

`script-src` uses `'unsafe-inline'` because the page has two inline `<script>` blocks.
The stricter fix is a SHA-256 hash per script:

```bash
grep -oPzo '(?s)<script>\K.*?(?=</script>)' dist/index.html | openssl dgst -sha256 -binary | openssl base64
```
But those hashes change on every content edit, and the *server* config would need updating
in lockstep with each rsync deploy — a silent page-breaker. Not worth it for a static site
with no user input and no third-party scripts.

`ufw` is inactive; port 80 is open at the OS level and access is governed by the cloud
firewall / security group instead.
