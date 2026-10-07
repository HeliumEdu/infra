function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Send the status route to the hosted status page instead of the SPA
    if (uri === '/status' || uri.startsWith('/status/')) {
        return {
            statusCode: 302,
            statusDescription: 'Found',
            headers: {
                location: { value: 'https://status.heliumedu.com' }
            }
        };
    }

    // If the request is for a file with an extension (assets), serve it directly
    if (uri.includes('.')) {
        return request;
    }

    // For all other requests (SPA routes), serve index.html
    request.uri = '/index.html';

    return request;
}
