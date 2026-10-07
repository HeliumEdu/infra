import cf from 'cloudfront';

const kvs = cf.kvs();

async function handler(event) {
    const request = event.request;
    const uri = request.uri;

    // If the request is for a file with an extension (assets), serve it directly
    if (uri.includes('.')) {
        return request;
    }

    const path = uri.length > 1 && uri.endsWith('/') ? uri.slice(0, -1) : uri;

    try {
        // Cross-host redirects, "<status> <location>", synced from projects/frontend on deploy
        const value = await kvs.get(path);
        const separator = value.indexOf(' ');
        const status = Number(value.slice(0, separator));

        return {
            statusCode: status,
            statusDescription: status === 301 ? 'Moved Permanently' : 'Found',
            headers: {
                location: { value: value.slice(separator + 1) }
            }
        };
    } catch (err) {
        // No entry (or the store is unavailable): fall through to the SPA
    }

    // For all other requests (SPA routes), serve index.html
    request.uri = '/index.html';

    return request;
}
