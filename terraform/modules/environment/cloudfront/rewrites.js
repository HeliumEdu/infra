function handler(event) {
    var request = event.request;
    var uri = request.uri;

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
        '/press': '/',
        '/docs': '/'
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

    if (normalized === '/support' || normalized === '/contact') {
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
