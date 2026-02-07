function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // If the request is for a file with an extension (assets), serve it directly
    if (uri.includes('.')) {
        return request;
    }

    // For all other requests (SPA routes), serve index.html
    request.uri = '/index.html';

    return request;
}
