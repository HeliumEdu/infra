function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Send the status route to the hosted status page instead of the static site
    if (uri === '/status' || uri.startsWith('/status/')) {
        return {
            statusCode: 302,
            statusDescription: 'Found',
            headers: {
                location: { value: 'https://status.heliumedu.com' }
            }
        };
    }

    return request;
}
