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
