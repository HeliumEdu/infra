import cf from 'cloudfront';

const kvs = cf.kvs();

async function handler(event) {
    const request = event.request;
    const uri = request.uri;

    // Redirects are extensionless pages, so skip the lookup for assets
    if (uri.includes('.')) {
        return request;
    }

    const path = uri.length > 1 && uri.endsWith('/') ? uri.slice(0, -1) : uri;

    try {
        // Values are "<status> <location>", synced from projects/www on deploy
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
        // No entry (or the store is unavailable): serve the site as usual
    }

    if (!uri.endsWith('/')) {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                location: { value: uri + '/' + toQueryString(request.querystring) }
            }
        };
    }

    return request;
}

function toQueryString(querystring) {
    const pairs = [];
    for (const key in querystring) {
        const entry = querystring[key];
        const values = entry.multiValue ? entry.multiValue : [entry];
        for (const value of values) {
            pairs.push(value.value === '' ? key : key + '=' + value.value);
        }
    }
    return pairs.length ? '?' + pairs.join('&') : '';
}
