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

## Pre-cutover audit: Elastic IP 54.84.230.185 (2026-08-13)

An Elastic IP was allocated and associated with the EC2 instance. Before pointing
`arcrayde.com` at it, the goal is to answer three questions: is the EIP really on
*this* box, does this box actually serve the site, and what breaks the moment DNS
moves. None of these should be assumed.

### Confirming the EIP is attached to this instance

```bash
curl -s https://ifconfig.me
```
Asks an outside service what source IP it sees. This is the only reliable way to
learn your *public* address from inside the box — `ip addr` only ever shows the
private VPC address (`172.31.91.81`), because AWS does the public↔private NAT out
at the gateway, not on the instance's NIC. Returned `54.84.230.185`, so the EIP is
correctly associated.

```bash
curl -s -H "X-aws-ec2-metadata-token: $TOK" http://169.254.169.254/latest/meta-data/public-ipv4
```
The instance metadata service — `169.254.169.254` is a link-local address every EC2
instance can reach, serving facts about itself. Ubuntu images now require IMDSv2, so
you must first `PUT` to `/latest/api/token` and pass the token back in a header;
plain unauthenticated `GET` (IMDSv1) just hangs. Blocked by the sandbox here, but
`ifconfig.me` already answered the question.

### Why you cannot test your own Elastic IP from the instance

```bash
curl --max-time 8 -H "Host: arcrayde.com" http://54.84.230.185/
```
Times out — and this is **not** evidence of a problem. Traffic an instance sends to
its own public IP leaves toward the internet gateway and is not hairpinned back in,
so the packets simply die. The security group's inbound rules for port 80/443 can
therefore only be verified from an outside network or the AWS console. Test from a
phone on cellular, not from the box.

```bash
curl -s -H "Host: arcrayde.com" http://127.0.0.1/ | head -c 300
```
The correct local test instead. The `Host` header is mandatory: nginx picks a server
block by hostname, and a bare-IP request matches the `000-catch-all` block, which
answers `444` (connection closed, no response) — which curl reports as status `000`.
A `000` here means "the catch-all did its job", not "nginx is down". With the header
it returns the real Astro `index.html`, so nginx and the `dist/` root are correct.

### Establishing what is live today

```bash
dig @ns1.siteground.net arcrayde.com A +noall +answer
```
Queries SiteGround's nameserver **directly** rather than the local resolver. A plain
`dig` returns whatever a cache holds, with a countdown TTL; asking the authoritative
server gives the record as configured, including its true TTL. Result: apex and `www`
both point at `34.174.73.152` with TTL **86400** (24 hours).

```bash
curl -sI https://arcrayde.com/
```
Headers only (`-I`). The reply carries `link: <https://arcrayde.com/wp-json/>` and
`x-httpd-modphp: 1` — the live site at that IP is still the **WordPress install on
SiteGround**, served over working HTTPS. So this is a platform migration, not a
server move, and HTTPS is a capability the current site has and the new box does not.

Critically, there is **no `strict-transport-security` header** in that response. Had
HSTS been set, browsers would refuse plain HTTP after the cutover and the site would
be hard-down until TLS worked. Absent it, an HTTP-only window degrades rather than
breaks.

```bash
dig +short arcrayde.com MX
```
Confirms mail routes to `mx*.antispam.mailspamprotection.com` (SiteGround). MX and A
records are independent, so repointing the A record does not touch email — but the
check is worth making before every DNS change, because moving *nameservers* would.

```bash
which certbot
```
Not installed. Combined with `ss -tlnp` showing a listener on `:80` but nothing on
`:443`, the new box is HTTP-only today.

### Verifying the security group from outside (2026-08-13)

Inbound rules were added for HTTP (TCP 80) and HTTPS (TCP 443), both from
`0.0.0.0/0`. Since the instance cannot reach its own Elastic IP (see above), the
rules have to be proven from an external network. `check-host.net` runs a plain TCP
connect from nodes in several countries and returns JSON — enough to answer the
question without waiting to be somewhere else.

```bash
curl -s -H "Accept: application/json" \
  "https://check-host.net/check-tcp?host=54.84.230.185:80&max_nodes=3"
```
Queues the check and returns a `request_id`. The `Accept: application/json` header is
required — without it the service returns an HTML page instead of JSON.

```bash
curl -s -H "Accept: application/json" \
  "https://check-host.net/check-result/<request_id>"
```
Fetches results a few seconds later; the check is asynchronous, so an immediate poll
comes back empty. Port 80 connected from Bulgaria, Moldova and Slovenia in ~0.12s
each, with no `error` key — the rule works.

**Reading the port 443 result is the useful part.** All three nodes returned
`{"error":"Connection refused"}`, which is the *good* outcome here:

- **Connection refused** — a packet reached the host and the kernel actively rejected
  it, because nothing is listening on 443 yet. This proves the security group is
  letting 443 through.
- **Timed out** — the packet vanished with no reply. That is what a security group
  block looks like, because AWS silently *drops* disallowed traffic rather than
  rejecting it.

So "refused" confirms the rule; "timeout" would have meant the rule was missing or
wrong. This refused-vs-timeout distinction is the general way to tell a firewall
problem from a service problem, and it is worth reaching for any time a port seems
closed.

```bash
ip -6 addr show scope global
```
Checks for a routable IPv6 address. There is none, so the IPv4-only inbound rules are
sufficient. Worth knowing because the nginx server blocks also `listen [::]:80` — if
IPv6 were ever enabled on the instance, matching `::/0` rules would be needed or
IPv6 clients would silently time out while IPv4 clients worked fine.

### Lowering TTLs before the cutover (2026-08-13)

TTL is set per *record*, not per domain, so lowering the apex `A` leaves `www` — and
every other record — untouched. The first edit changed only `arcrayde.com`; `www`
stayed at 86400 and had to be done separately. All records were then set to 300.

```bash
dig @ns1.siteground.net arcrayde.com A +noall +answer
dig @ns1.siteground.net www.arcrayde.com A +noall +answer
```
Always query the **authoritative** nameserver when verifying an edit. A plain `dig`
answers from a cache and shows a counting-down remainder of the *old* TTL, which
looks like the change failed. Checking `ns2` as well confirms both of SiteGround's
servers carry the edit, distinguishing a genuine failure from one server lagging.

```bash
dig @ns1.siteground.net arcrayde.com SOA +noall +answer
```
The **SOA serial** is the zone's version number, and it increments on every committed
change — here it moved `33` → `36` across three saves. This is the reliable way to
tell "the panel never saved my edit" from "it saved but hasn't propagated": if the
serial has not moved, nothing was committed. Capture the serial *before* an edit so
the comparison is available afterwards.

```bash
dig @ns1.siteground.net www.arcrayde.com CNAME +noall +answer
```
Run while diagnosing the stuck `www` record, to rule out its being a CNAME (a CNAME's
TTL lives on the alias, not the target). It returned nothing, confirming a real A
record. Note that an `ANY` query is not a useful substitute — SiteGround answers it
with `HINFO "rfc8482"`, the standard modern refusal to enumerate a record set.

### A side effect of moving the A record: SPF

```bash
dig @ns1.siteground.net arcrayde.com TXT +noall +answer
```
Returns `v=spf1 +a +mx include:...spf.auto.dnssmarthost.net ~all`.

The `+a` mechanism means **"whatever IP the domain's A record points at is authorised
to send mail as this domain."** So repointing the A record silently moves that
authorisation from the SiteGround host to the EC2 box — the SPF record's *text* never
changes, but its *meaning* does. Worth being deliberate about: it widens mail
authority to a web server that has no reason to send mail. Dropping `+a` (leaving
`+mx` and the `include:`) is the tighter option, since mail is handled by
`mx*.antispam.mailspamprotection.com`, not by the web host.

After the cutover is confirmed stable, raise TTLs back to 3600 or 86400. Leaving them
at 300 permanently means every resolver re-queries constantly, and a nameserver
outage becomes visible to visitors within five minutes instead of being absorbed by
long caches.
