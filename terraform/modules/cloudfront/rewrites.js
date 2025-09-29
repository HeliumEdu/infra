function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } else if (!uri.includes('.')) {
        request.uri += '.html';
    }

    if (uri === '/info') {
        request.uri = '/assets/info.json';
    }

    return request;
}