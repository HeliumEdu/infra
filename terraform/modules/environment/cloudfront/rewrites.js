function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // SEO files (sitemap, robots) used to be served by the legacy frontend at
    // www.heliumedu.com. They now live on landing.heliumedu.com — redirect so
    // crawlers and external links don't 404 during the legacy-shutdown window.
    var seoRedirects = {
        '/sitemap.xml': 'https://landing.heliumedu.com/sitemap.xml',
        '/sitemap-index.xml': 'https://landing.heliumedu.com/sitemap-index.xml',
        '/sitemap-0.xml': 'https://landing.heliumedu.com/sitemap-0.xml',
        '/robots.txt': 'https://landing.heliumedu.com/robots.txt'
    };
    if (seoRedirects[uri] !== undefined) {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': seoRedirects[uri]
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
        '/press': '/about'
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

    if (normalized === '/support' || normalized === '/contact' || normalized === '/docs') {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': 'https://support.heliumedu.com'
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
