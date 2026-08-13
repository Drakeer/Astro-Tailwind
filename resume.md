# Resume — arcrayde.com DNS cutover

**Paused:** 2026-08-13
**Status:** All `arcrayde.com` records verified at TTL 300 on both SiteGround nameservers (SOA serial 33→36 confirming commits). The 24h propagation wait is running before DNS cutover. Flagged that the SPF `+a` mechanism will silently move mail-sending authority to the EC2 box when the A record flips.

---

All records confirmed at TTL 300 on both `ns1` and `ns2`:

| Record | TTL |
|---|---|
| `arcrayde.com` A | 300 |
| `www.arcrayde.com` A | 300 |
| `arcrayde.com` MX ×3 | 300 |
| `arcrayde.com` TXT (SPF) | 300 |

The SOA serial moved **33 → 36**, which independently confirms three edits actually committed — that's the number to watch whenever a panel edit seems not to take.

## One thing your TXT record does that you should decide about

Your SPF record is:

```
v=spf1 +a +mx include:arcrayde.com.spf.auto.dnssmarthost.net ~all
```

The **`+a`** mechanism means *"whatever IP the domain's A record points at is authorized to send mail as this domain."*

So when you flip the A record to `54.84.230.185`, the SPF text doesn't change but its **meaning** does — mail-sending authority silently transfers from the SiteGround host to your EC2 box. Nothing breaks, and email delivery is unaffected either way since inbound mail follows MX and your real senders are covered by `+mx` and the `include:`.

But it means a static web server that has no business sending mail becomes SPF-authorized to send as your domain. If that box is ever compromised, spam from it passes SPF checks. The tighter configuration is to drop `+a` and keep `+mx include:... ~all`. Your call — it's not urgent and not part of the cutover, just something that changes underneath you without any visible edit.

## Where you stand

The 24-hour clock is now running, and it runs from the **`www` change**, not the apex — resolvers that cached the old 86400 record just before you saved can legitimately hold it until roughly this time tomorrow. Don't flip the IPs before then, or a rollback would take a day.

Nothing else is blocking. Remaining sequence: install certbot → flip both A records to `54.84.230.185` → issue the cert immediately → then add HSTS at `max-age=300`.

I can install certbot and pre-stage the TLS server block during the wait so the post-cutover window is as short as possible. Say the word — I've held off because it's a system package install on your server.

One more for after you're stable: raise the TTLs back to 3600 or 86400. Leaving them at 300 permanently makes every resolver re-query constantly and turns any nameserver hiccup into visitor-facing downtime within five minutes.

COMMANDS.md updated with the TTL/SOA diagnostics and the SPF note, committed and pushed to `worktree-eip-dns-cutover-notes`.
