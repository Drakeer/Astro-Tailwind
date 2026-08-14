# arcrayde.com -- static Astro site served straight from disk by nginx.
# HTTP only for now; TLS is the next lesson.

##
# Canonical host redirect: www -> apex.
# The site's own <link rel="canonical"> points at https://arcrayde.com/, so
# apex is canonical and www must not serve a duplicate copy (bad for SEO and
# it doubles the surface you have to reason about).
##
server {
    server_name www.arcrayde.com;

    # 301 = permanent. Use 302 while testing if you are unsure, because
    # browsers cache 301s aggressively and a wrong one is painful to undo.
    return 301 https://arcrayde.com$request_uri;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/arcrayde.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/arcrayde.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

##
# The site itself.
##
server {
    server_name arcrayde.com;

    root /home/claude-agent/sysadmin/portfolio/dist;
    index index.html;

    charset utf-8;

    # Per-site logs, so this site's traffic is separable from everything else.
    access_log /var/log/nginx/arcrayde.com.access.log;
    error_log  /var/log/nginx/arcrayde.com.error.log;

    # Server-level security headers. Inherited by any location that does NOT
    # declare its own add_header -- every location below that sets
    # Cache-Control therefore has to re-include this file.
    include snippets/security-headers.conf;

    ##
    # Hashed build assets: /_astro/index.BRq_hIYa.css
    # The content hash is in the filename, so the URL changes whenever the
    # bytes change. That makes it safe to cache effectively forever.
    # "immutable" additionally tells the browser not to even revalidate on a
    # hard refresh.
    # "^~" stops nginx evaluating the regex locations below for this prefix.
    ##
    location ^~ /_astro/ {
        include snippets/security-headers.conf;
        add_header Cache-Control "public, max-age=31536000, immutable" always;
        try_files $uri =404;
    }

    ##
    # Unhashed static assets (favicon, images, fonts, robots.txt...).
    # These keep the SAME filename across deploys, so they must NOT be
    # cached for a year -- you would have no way to push an update.
    # 7 days is a reasonable middle ground.
    ##
    location ~* \.(?:css|js|mjs|ico|svg|png|jpg|jpeg|gif|webp|avif|woff2|woff|ttf|otf|eot|mp4|webm|pdf|txt|xml|json|webmanifest)$ {
        include snippets/security-headers.conf;
        add_header Cache-Control "public, max-age=604800" always;
        try_files $uri =404;
    }

    ##
    # Block dotfiles (.git, .env, editor swap files), but explicitly allow
    # /.well-known/ -- Let's Encrypt's HTTP-01 challenge lives there and a
    # blanket dotfile deny is a classic way to break certbot next lesson.
    ##
    location ~ /\.(?!well-known) {
        deny all;
        access_log off;
        log_not_found off;
    }

    ##
    # Everything else: HTML pages and directory indexes.
    #
    # "no-cache" does NOT mean "don't cache" -- it means "cache it, but always
    # revalidate before reuse". nginx sends ETag/Last-Modified, so the browser
    # gets a cheap 304 when nothing changed, and picks up a deploy instantly.
    # Caching HTML by time instead is how a deploy becomes invisible for hours.
    ##
    location / {
        include snippets/security-headers.conf;
        add_header Cache-Control "no-cache" always;
        try_files $uri $uri/ =404;
    }

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/arcrayde.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/arcrayde.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    if ($host = arcrayde.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;
    server_name arcrayde.com;
    return 404; # managed by Certbot


}
server {
    if ($host = www.arcrayde.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;
    server_name www.arcrayde.com;
    return 404; # managed by Certbot


}