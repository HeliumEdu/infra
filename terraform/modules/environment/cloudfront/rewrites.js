function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Shared static assets (SEO, favicon, social card, app association files)
    // used to be served by the legacy frontend at www.heliumedu.com. They now
    // live on landing.heliumedu.com (the new marketing site) — redirect so
    // crawlers, browsers, social platforms, and the iOS/Android apps don't
    // 404 during the legacy-shutdown window. After the Aug 1 cutover (when
    // www becomes the marketing site directly), this whole function is
    // deleted in phase 1.
    var sharedAssetRedirects = {
        '/sitemap.xml': 'https://landing.heliumedu.com/sitemap.xml',
        '/sitemap-index.xml': 'https://landing.heliumedu.com/sitemap-index.xml',
        '/sitemap-0.xml': 'https://landing.heliumedu.com/sitemap-0.xml',
        '/robots.txt': 'https://landing.heliumedu.com/robots.txt',
        '/favicon.ico': 'https://landing.heliumedu.com/favicon.ico',
        '/favicon.png': 'https://landing.heliumedu.com/favicon.png',
        '/img/og-default.png': 'https://landing.heliumedu.com/img/og-default.png',
        '/img/helium-logo.png': 'https://landing.heliumedu.com/img/helium-logo.png',
        '/img/helium-logo-square.png': 'https://landing.heliumedu.com/img/helium-logo-square.png',
        '/img/support-patreon.svg': 'https://landing.heliumedu.com/img/support-patreon.svg',
        '/img/support-patreon.png': 'https://landing.heliumedu.com/img/support-patreon.png',
        '/.well-known/apple-app-site-association': 'https://landing.heliumedu.com/.well-known/apple-app-site-association',
        '/.well-known/assetlinks.json': 'https://landing.heliumedu.com/.well-known/assetlinks.json'
    };
    if (sharedAssetRedirects[uri] !== undefined) {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': sharedAssetRedirects[uri]
                }
            }
        };
    }

    var normalized = uri;
    if (normalized.length > 1 && normalized.endsWith('/')) {
        normalized = normalized.slice(0, -1);
    }
    if (normalized.endsWith('.html')) {
        normalized = normalized.slice(0, -5);
    }

    var landingPath = {
        '/': '/',
        '/index': '/',
        '/about': '/about',
        '/terms': '/terms',
        '/privacy': '/privacy',
        '/press': '/press'
    };
    if (landingPath[normalized] !== undefined) {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': 'https://landing.heliumedu.com' + landingPath[normalized]
                }
            }
        };
    }

    // Bridge: all /support* paths on legacy www → landing (where the new portal
    // actually lives until the Aug 1 cutover). Target MUST be landing here, not
    // www.heliumedu.com/support — pointing back at the same host would loop.
    if (normalized === '/support' || normalized.startsWith('/support/')) {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': 'https://landing.heliumedu.com' + normalized
                }
            }
        };
    }

    // /contact points at the canonical www.heliumedu.com/support/submit URL
    // (the branded ticket form). During the legacy period, the bridge rule
    // above catches the follow-up request and forwards to landing. At cutover,
    // this becomes a single 301 to the live www marketing site without any
    // further edits.
    if (normalized === '/contact') {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': 'https://www.heliumedu.com/support/submit'
                }
            }
        };
    }

    if (normalized === '/docs') {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': 'https://api.heliumedu.com/docs'
                }
            }
        };
    }

    if (uri.endsWith('.html')) {
        var newUri = uri.slice(0, -5);
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': newUri
                }
            }
        };
    }

    if (uri === '/info') {
        request.uri = '/assets/info.json';
    } else if (!uri.includes('.') && !uri.endsWith('/')) {
        request.uri += '.html';
    } else if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }

    return request;
}
