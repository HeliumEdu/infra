function handler(event) {
    var request = event.request;
    var uri = request.uri;

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
    } else if (uri === "/index") {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': {
                    'value': "/"
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