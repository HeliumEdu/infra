// Cross-host paths, mirrored from projects/frontend lib/config/app_router.dart (External redirects)
const externalRedirects = {
    '/status': 'https://status.heliumedu.com',
    '/support': 'https://www.heliumedu.com/support',
    '/contact': 'https://www.heliumedu.com/contact',
    '/docs': 'https://api.heliumedu.com/docs',
    '/api': 'https://api.heliumedu.com'
};

function handler(event) {
    const request = event.request;
    const uri = request.uri;

    // If the request is for a file with an extension (assets), serve it directly
    if (uri.includes('.')) {
        return request;
    }

    const path = uri.length > 1 && uri.endsWith('/') ? uri.slice(0, -1) : uri;

    if (Object.prototype.hasOwnProperty.call(externalRedirects, path)) {
        return {
            statusCode: 302,
            statusDescription: 'Found',
            headers: {
                location: { value: externalRedirects[path] }
            }
        };
    }

    // For all other requests (SPA routes), serve index.html
    request.uri = '/index.html';

    return request;
}
